# Implementation Plan - Frontend

## Visão Geral

Implementação do frontend usando React 18+ com TypeScript, Material-UI e Konva.js para o canvas de fluxogramas.

## Escolha de Framework: React

**Justificativa**:
- Ecossistema maduro e rico
- Excelente para aplicações complexas
- React-Konva para canvas
- Material-UI components prontos
- Grande comunidade

## Estrutura de Componentes

### 1. Layout Principal (Workspace)

#### Workspace.tsx
```typescript
import { useState } from 'react';
import { Box, Drawer } from '@mui/material';
import ObjectTree from './ObjectTree';
import TabManager from './TabManager';
import PropertyInspector from './PropertyInspector';
import Toolbar from './Toolbar';
import StatusBar from './StatusBar';

interface WorkspaceProps {}

export const Workspace: React.FC<WorkspaceProps> = () => {
  const [leftPanelOpen, setLeftPanelOpen] = useState(true);
  const [rightPanelOpen, setRightPanelOpen] = useState(true);
  
  return (
    <Box sx={{ display: 'flex', height: '100vh', overflow: 'hidden' }}>
      {/* Top Toolbar */}
      <Toolbar />
      
      {/* Left Panel - Object Tree */}
      <Drawer
        variant="persistent"
        open={leftPanelOpen}
        sx={{
          width: 250,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: 250,
            marginTop: '64px', // Toolbar height
          },
        }}
      >
        <ObjectTree />
      </Drawer>
      
      {/* Center Panel - Tabs */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          marginTop: '64px',
          overflow: 'hidden',
        }}
      >
        <TabManager />
      </Box>
      
      {/* Right Panel - Properties */}
      <Drawer
        variant="persistent"
        anchor="right"
        open={rightPanelOpen}
        sx={{
          width: 300,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: 300,
            marginTop: '64px',
          },
        }}
      >
        <PropertyInspector />
      </Drawer>
      
      {/* Bottom Status Bar */}
      <StatusBar />
    </Box>
  );
};
```

### 2. Object Tree (Left Panel)

#### ObjectTree.tsx
```typescript
import { TreeView, TreeItem } from '@mui/lab';
import { ExpandMore, ChevronRight } from '@mui/icons-material';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../../store';
import { openTab } from '../../store/workspace';

export const ObjectTree: React.FC = () => {
  const { forms, flows, reports } = useSelector((state: RootState) => state.objects);
  const dispatch = useDispatch();
  
  const handleNodeSelect = (type: string, id: number) => {
    dispatch(openTab({ type, id }));
  };
  
  return (
    <TreeView
      defaultCollapseIcon={<ExpandMore />}
      defaultExpandIcon={<ChevronRight />}
    >
      <TreeItem nodeId="forms" label="Formulários">
        {forms.map(form => (
          <TreeItem
            key={form.id}
            nodeId={`form-${form.id}`}
            label={form.nome}
            onDoubleClick={() => handleNodeSelect('form', form.id)}
          />
        ))}
      </TreeItem>
      
      <TreeItem nodeId="flows" label="Fluxos">
        {flows.map(flow => (
          <TreeItem
            key={flow.id}
            nodeId={`flow-${flow.id}`}
            label={flow.nome}
            onDoubleClick={() => handleNodeSelect('flow', flow.id)}
          />
        ))}
      </TreeItem>
      
      <TreeItem nodeId="reports" label="Relatórios">
        {reports.map(report => (
          <TreeItem
            key={report.id}
            nodeId={`report-${report.id}`}
            label={report.nome}
            onDoubleClick={() => handleNodeSelect('report', report.id)}
          />
        ))}
      </TreeItem>
    </TreeView>
  );
};
```

### 3. Tab Manager (Center Panel)

#### TabManager.tsx
```typescript
import { useState } from 'react';
import { Tabs, Tab, Box, IconButton } from '@mui/material';
import { Close, Add } from '@mui/icons-material';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../../store';
import { closeTab, setActiveTab } from '../../store/workspace';
import FormDesigner from '../form-designer/FormDesigner';
import FlowEditor from '../flow-editor/FlowEditor';

export const TabManager: React.FC = () => {
  const { openTabs, activeTabId } = useSelector((state: RootState) => state.workspace);
  const dispatch = useDispatch();
  
  const handleTabChange = (event: React.SyntheticEvent, newValue: string) => {
    dispatch(setActiveTab(newValue));
  };
  
  const handleCloseTab = (tabId: string) => {
    dispatch(closeTab(tabId));
  };
  
  const renderTabContent = (tab: any) => {
    switch (tab.type) {
      case 'form':
        return <FormDesigner formId={tab.id} />;
      case 'flow':
        return <FlowEditor flowId={tab.id} />;
      default:
        return <div>Unknown tab type</div>;
    }
  };
  
  return (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Tab Headers */}
      <Tabs
        value={activeTabId}
        onChange={handleTabChange}
        variant="scrollable"
        scrollButtons="auto"
      >
        {openTabs.map(tab => (
          <Tab
            key={tab.id}
            value={tab.id}
            label={
              <Box sx={{ display: 'flex', alignItems: 'center' }}>
                {tab.title}
                <IconButton
                  size="small"
                  onClick={(e) => {
                    e.stopPropagation();
                    handleCloseTab(tab.id);
                  }}
                >
                  <Close fontSize="small" />
                </IconButton>
              </Box>
            }
          />
        ))}
      </Tabs>
      
      {/* Tab Content */}
      <Box sx={{ flexGrow: 1, overflow: 'auto' }}>
        {openTabs.map(tab => (
          <Box
            key={tab.id}
            sx={{
              display: tab.id === activeTabId ? 'block' : 'none',
              height: '100%',
            }}
          >
            {renderTabContent(tab)}
          </Box>
        ))}
      </Box>
    </Box>
  );
};
```

### 4. Property Inspector (Right Panel)

#### PropertyInspector.tsx
```typescript
import { TextField, Select, MenuItem, ColorPicker } from '@mui/material';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../../store';
import { updateComponentProperty } from '../../store/forms';

export const PropertyInspector: React.FC = () => {
  const { selectedComponent } = useSelector((state: RootState) => state.selection);
  const dispatch = useDispatch();
  
  if (!selectedComponent) {
    return <div>Nenhum componente selecionado</div>;
  }
  
  const handlePropertyChange = (property: string, value: any) => {
    dispatch(updateComponentProperty({
      componentId: selectedComponent.id,
      property,
      value
    }));
  };
  
  return (
    <Box sx={{ p: 2 }}>
      <Typography variant="h6">Propriedades</Typography>
      
      {/* Common Properties */}
      <TextField
        label="Nome"
        value={selectedComponent.nome}
        onChange={(e) => handlePropertyChange('nome', e.target.value)}
        fullWidth
        margin="normal"
      />
      
      <TextField
        label="X"
        type="number"
        value={selectedComponent.posicao_x}
        onChange={(e) => handlePropertyChange('posicao_x', parseInt(e.target.value))}
        fullWidth
        margin="normal"
      />
      
      <TextField
        label="Y"
        type="number"
        value={selectedComponent.posicao_y}
        onChange={(e) => handlePropertyChange('posicao_y', parseInt(e.target.value))}
        fullWidth
        margin="normal"
      />
      
      {/* Type-specific properties */}
      {selectedComponent.tipo === 'BUTTON' && (
        <>
          <TextField
            label="Texto"
            value={selectedComponent.propriedades.text}
            onChange={(e) => handlePropertyChange('propriedades.text', e.target.value)}
            fullWidth
            margin="normal"
          />
          
          <ColorPicker
            label="Cor"
            value={selectedComponent.estilo.background_color}
            onChange={(color) => handlePropertyChange('estilo.background_color', color)}
          />
        </>
      )}
    </Box>
  );
};
```

### 5. Form Designer

#### FormDesigner.tsx
```typescript
import { useState, useRef } from 'react';
import { Box, Paper } from '@mui/material';
import { useDrop } from 'react-dnd';
import ComponentPalette from './ComponentPalette';
import ComponentWrapper from './ComponentWrapper';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../../store';
import { addComponent, updateComponent } from '../../store/forms';

interface FormDesignerProps {
  formId: number;
}

export const FormDesigner: React.FC<FormDesignerProps> = ({ formId }) => {
  const form = useSelector((state: RootState) => 
    state.forms.items.find(f => f.id === formId)
  );
  const dispatch = useDispatch();
  const canvasRef = useRef<HTMLDivElement>(null);
  
  const [{ isOver }, drop] = useDrop(() => ({
    accept: 'COMPONENT',
    drop: (item: any, monitor) => {
      const offset = monitor.getClientOffset();
      if (offset && canvasRef.current) {
        const canvasRect = canvasRef.current.getBoundingClientRect();
        const x = offset.x - canvasRect.left;
        const y = offset.y - canvasRect.top;
        
        dispatch(addComponent({
          formId,
          type: item.componentType,
          x,
          y
        }));
      }
    },
    collect: (monitor) => ({
      isOver: monitor.isOver()
    })
  }));
  
  return (
    <Box sx={{ display: 'flex', height: '100%' }}>
      {/* Component Palette */}
      <ComponentPalette />
      
      {/* Canvas */}
      <Box
        ref={(node) => {
          canvasRef.current = node;
          drop(node);
        }}
        sx={{
          flexGrow: 1,
          position: 'relative',
          backgroundColor: '#f5f5f5',
          backgroundImage: 
            'linear-gradient(rgba(0,0,0,.05) 1px, transparent 1px), ' +
            'linear-gradient(90deg, rgba(0,0,0,.05) 1px, transparent 1px)',
          backgroundSize: '10px 10px',
          overflow: 'auto'
        }}
      >
        <Paper
          sx={{
            position: 'absolute',
            left: 50,
            top: 50,
            width: form.largura,
            height: form.altura,
            backgroundColor: 'white',
            boxShadow: 3
          }}
        >
          {form.components?.map(component => (
            <ComponentWrapper
              key={component.id}
              component={component}
            />
          ))}
        </Paper>
      </Box>
    </Box>
  );
};
```

#### ComponentPalette.tsx
```typescript
import { Box, Paper, Typography } from '@mui/material';
import { useDrag } from 'react-dnd';

const COMPONENTS = [
  { type: 'TEXTBOX', label: 'TextBox', icon: '📝' },
  { type: 'BUTTON', label: 'Button', icon: '🔘' },
  { type: 'CHECKBOX', label: 'CheckBox', icon: '☑' },
  { type: 'COMBOBOX', label: 'ComboBox', icon: '🔽' },
  { type: 'GRID', label: 'Grid', icon: '📋' },
  { type: 'LABEL', label: 'Label', icon: '📄' },
];

const PaletteItem: React.FC<{ type: string; label: string; icon: string }> = ({ 
  type, label, icon 
}) => {
  const [{ isDragging }, drag] = useDrag(() => ({
    type: 'COMPONENT',
    item: { componentType: type },
    collect: (monitor) => ({
      isDragging: monitor.isDragging()
    })
  }));
  
  return (
    <Paper
      ref={drag}
      sx={{
        p: 1,
        m: 1,
        cursor: 'move',
        opacity: isDragging ? 0.5 : 1,
        '&:hover': {
          backgroundColor: 'action.hover'
        }
      }}
    >
      <Typography>{icon} {label}</Typography>
    </Paper>
  );
};

export const ComponentPalette: React.FC = () => {
  return (
    <Box sx={{ width: 200, borderRight: 1, borderColor: 'divider', p: 1 }}>
      <Typography variant="h6">Components</Typography>
      {COMPONENTS.map(comp => (
        <PaletteItem key={comp.type} {...comp} />
      ))}
    </Box>
  );
};
```

### 6. Flow Editor

#### FlowEditor.tsx
```typescript
import { useState, useRef } from 'react';
import { Stage, Layer } from 'react-konva';
import { Box, Paper } from '@mui/material';
import FlowNode from './FlowNode';
import FlowConnection from './FlowConnection';
import RadialMenu from './RadialMenu';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../../store';

interface FlowEditorProps {
  flowId: number;
}

export const FlowEditor: React.FC<FlowEditorProps> = ({ flowId }) => {
  const flow = useSelector((state: RootState) => 
    state.flows.items.find(f => f.id === flowId)
  );
  const [zoom, setZoom] = useState(1);
  const [stagePos, setStagePos] = useState({ x: 0, y: 0 });
  const [showRadialMenu, setShowRadialMenu] = useState(false);
  const [radialMenuPos, setRadialMenuPos] = useState({ x: 0, y: 0 });
  
  const handleWheel = (e: any) => {
    e.evt.preventDefault();
    
    const scaleBy = 1.1;
    const stage = e.target.getStage();
    const oldScale = stage.scaleX();
    const pointer = stage.getPointerPosition();
    
    const newScale = e.evt.deltaY < 0 ? oldScale * scaleBy : oldScale / scaleBy;
    
    setZoom(newScale);
  };
  
  const handleContextMenu = (e: any) => {
    e.evt.preventDefault();
    const stage = e.target.getStage();
    const pos = stage.getPointerPosition();
    setRadialMenuPos(pos);
    setShowRadialMenu(true);
  };
  
  return (
    <Box sx={{ width: '100%', height: '100%', position: 'relative' }}>
      {/* Toolbar */}
      <Paper sx={{ position: 'absolute', top: 10, left: 10, zIndex: 1, p: 1 }}>
        <Button onClick={() => setZoom(zoom * 1.1)}>+</Button>
        <Typography sx={{ display: 'inline', mx: 1 }}>{Math.round(zoom * 100)}%</Typography>
        <Button onClick={() => setZoom(zoom / 1.1)}>-</Button>
      </Paper>
      
      {/* Canvas */}
      <Stage
        width={window.innerWidth}
        height={window.innerHeight}
        scaleX={zoom}
        scaleY={zoom}
        x={stagePos.x}
        y={stagePos.y}
        draggable
        onWheel={handleWheel}
        onContextMenu={handleContextMenu}
        onDragEnd={(e) => {
          setStagePos({
            x: e.target.x(),
            y: e.target.y()
          });
        }}
      >
        <Layer>
          {/* Grid */}
          {/* ... grid lines */}
          
          {/* Connections */}
          {flow.connections?.map(conn => (
            <FlowConnection key={conn.id} connection={conn} />
          ))}
          
          {/* Nodes */}
          {flow.nodes?.map(node => (
            <FlowNode key={node.id} node={node} />
          ))}
        </Layer>
      </Stage>
      
      {/* Radial Menu */}
      {showRadialMenu && (
        <RadialMenu
          x={radialMenuPos.x}
          y={radialMenuPos.y}
          onClose={() => setShowRadialMenu(false)}
          onSelect={(nodeType) => {
            // Add node
            setShowRadialMenu(false);
          }}
        />
      )}
    </Box>
  );
};
```

#### FlowNode.tsx
```typescript
import { Group, Rect, Text, Circle } from 'react-konva';
import { useState } from 'react';

interface FlowNodeProps {
  node: {
    id: number;
    tipo: string;
    nome: string;
    posicao_x: number;
    posicao_y: number;
    largura: number;
    altura: number;
    cor: string;
  };
}

export const FlowNode: React.FC<FlowNodeProps> = ({ node }) => {
  const [isDragging, setIsDragging] = useState(false);
  
  return (
    <Group
      x={node.posicao_x}
      y={node.posicao_y}
      draggable
      onDragStart={() => setIsDragging(true)}
      onDragEnd={(e) => {
        setIsDragging(false);
        // Update node position in store
      }}
    >
      {/* Node body */}
      <Rect
        width={node.largura}
        height={node.altura}
        fill={node.cor}
        stroke={isDragging ? '#2196f3' : '#000'}
        strokeWidth={isDragging ? 3 : 1}
        cornerRadius={5}
        shadowBlur={isDragging ? 10 : 5}
      />
      
      {/* Node label */}
      <Text
        text={node.nome}
        fontSize={14}
        fill="#fff"
        width={node.largura}
        height={node.altura}
        align="center"
        verticalAlign="middle"
      />
      
      {/* Connection points */}
      <Circle
        x={node.largura / 2}
        y={0}
        radius={5}
        fill="#fff"
        stroke="#000"
      />
      <Circle
        x={node.largura / 2}
        y={node.altura}
        radius={5}
        fill="#fff"
        stroke="#000"
      />
    </Group>
  );
};
```

## State Management (Redux Toolkit)

### store/workspace.ts
```typescript
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface Tab {
  id: string;
  type: 'form' | 'flow' | 'report';
  objectId: number;
  title: string;
  isDirty: boolean;
}

interface WorkspaceState {
  openTabs: Tab[];
  activeTabId: string | null;
  leftPanelOpen: boolean;
  rightPanelOpen: boolean;
}

const initialState: WorkspaceState = {
  openTabs: [],
  activeTabId: null,
  leftPanelOpen: true,
  rightPanelOpen: true,
};

const workspaceSlice = createSlice({
  name: 'workspace',
  initialState,
  reducers: {
    openTab: (state, action: PayloadAction<{ type: string; id: number }>) => {
      const tabId = `${action.payload.type}-${action.payload.id}`;
      if (!state.openTabs.find(t => t.id === tabId)) {
        state.openTabs.push({
          id: tabId,
          type: action.payload.type as any,
          objectId: action.payload.id,
          title: `${action.payload.type} ${action.payload.id}`,
          isDirty: false
        });
      }
      state.activeTabId = tabId;
    },
    closeTab: (state, action: PayloadAction<string>) => {
      state.openTabs = state.openTabs.filter(t => t.id !== action.payload);
      if (state.activeTabId === action.payload) {
        state.activeTabId = state.openTabs[0]?.id || null;
      }
    },
    setActiveTab: (state, action: PayloadAction<string>) => {
      state.activeTabId = action.payload;
    }
  }
});

export const { openTab, closeTab, setActiveTab } = workspaceSlice.actions;
export default workspaceSlice.reducer;
```

## API Client

### services/api/client.ts
```typescript
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export const apiClient = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle errors
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Redirect to login
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### services/api/forms.ts
```typescript
import { apiClient } from './client';
import { Form, Component } from '../../types/form.types';

export const formsAPI = {
  getAll: () => apiClient.get<Form[]>('/forms'),
  
  getById: (id: number) => apiClient.get<Form>(`/forms/${id}`),
  
  create: (form: Partial<Form>) => apiClient.post<Form>('/forms', form),
  
  update: (id: number, form: Partial<Form>) => 
    apiClient.put<Form>(`/forms/${id}`, form),
  
  delete: (id: number) => apiClient.delete(`/forms/${id}`),
  
  getComponents: (formId: number) => 
    apiClient.get<Component[]>(`/forms/${formId}/components`),
};
```

## Responsive Design

### Theme Configuration
```typescript
import { createTheme } from '@mui/material/styles';

export const theme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#2ecc71',
    },
    background: {
      default: '#1e1e1e',
      paper: '#252526',
    },
  },
  typography: {
    fontFamily: 'Roboto, Inter, sans-serif',
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 4,
          textTransform: 'none',
        },
      },
    },
  },
});
```

## Testing Strategy

### Component Tests
```typescript
import { render, screen } from '@testing-library/react';
import { Workspace } from './Workspace';

describe('Workspace', () => {
  it('renders workspace layout', () => {
    render(<Workspace />);
    expect(screen.getByText('Formulários')).toBeInTheDocument();
  });
});
```

## Summary

O frontend implementa:
1. **Layout profissional** com painéis ajustáveis
2. **Form Designer** com drag & drop
3. **Flow Editor** com canvas Konva
4. **State management** com Redux
5. **API integration** com Axios
6. **Tema dark** moderno
7. **TypeScript** para type safety
8. **Componentização** clara e reutilizável
