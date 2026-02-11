# Maker AI - Análise do Frontend

## Visão Geral da Interface

O frontend do Maker AI é uma IDE completa com múltiplos painéis e editores especializados.

## Layout Principal (Workspace)

### Estrutura de 3 Painéis
```
┌────────────────────────────────────────────────────────────┐
│  Menu Bar / Toolbar                                        │
├──────────┬─────────────────────────────────┬───────────────┤
│          │                                 │               │
│  Object  │      Main Canvas               │  Properties   │
│  Tree    │      (Tabs)                    │  Inspector    │
│          │                                 │               │
│  [Left]  │      [Center]                  │  [Right]      │
│          │                                 │               │
│  200px   │      Flexible                  │  300px        │
│          │                                 │               │
│          │                                 │               │
├──────────┴─────────────────────────────────┴───────────────┤
│  Status Bar / Console                                      │
└────────────────────────────────────────────────────────────┘
```

### Painel Esquerdo: Object Tree
**Funcionalidade**: Navegação hierárquica de objetos

```
📁 Projeto
  ├── 📄 Formulários
  │   ├── 🖼 frmMain
  │   ├── 🖼 frmClientes
  │   └── 🖼 frmProdutos
  ├── 🔄 Fluxos (Action Flows)
  │   ├── ⚙ OnSaveClient
  │   ├── ⚙ CalculateTotal
  │   └── ⚙ SendEmail
  ├── 📊 Relatórios
  │   ├── 📄 RelVendas
  │   └── 📄 RelEstoque
  └── 🔍 Consultas
      ├── 📋 QryClientes
      └── 📋 QryProdutos
```

**Interações**:
- Click: Seleciona objeto
- Double-click: Abre no editor central
- Right-click: Menu contextual (Rename, Delete, Duplicate, Properties)
- Drag: Reordenar / Mover para pastas

**Implementação**:
```javascript
// Tree component structure
<TreeView>
  <TreeNode icon="folder" label="Formulários">
    <TreeNode icon="form" label="frmMain" onDoubleClick={openForm} />
  </TreeNode>
</TreeView>
```

### Painel Central: Tabs & Editors
**Sistema de Abas**: Múltiplos editores abertos simultaneamente

```
┌─────────────────────────────────────────────────────────┐
│ [frmMain] [OnSaveClient] [RelVendas] [+]              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│             Active Editor Content                      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │                                                 │  │
│  │   (Form Designer / Flow Editor / etc.)        │  │
│  │                                                 │  │
│  └─────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Tipos de Editores**:
1. **Form Designer** (WYSIWYG)
2. **Flow Editor** (Canvas de fluxograma)
3. **Report Designer** (Layout de relatórios)
4. **Query Designer** (Visual SQL builder)
5. **Code Editor** (Para scripts avançados)

**Tab Management**:
```javascript
const [tabs, setTabs] = useState([
  {id: 1, title: 'frmMain', type: 'form', content: {...}},
  {id: 2, title: 'OnSaveClient', type: 'flow', content: {...}}
]);

const addTab = (objectId, objectType) => {
  // Load object from backend
  // Create new tab
  // Set as active
};
```

### Painel Direito: Properties Inspector
**Funcionalidade**: Edição contextual de propriedades

**Contextual**: Muda baseado na seleção
```
If Button selected:
┌──────────────────────┐
│ Properties           │
├──────────────────────┤
│ Text: [Save____]     │
│ X: [100_] Y: [50_]   │
│ Width: [80__]        │
│ Height: [30__]       │
│ Color: [🎨]          │
│ Font: [Roboto ▼]    │
│ OnClick: [Flow ▼]    │
└──────────────────────┘

If Flow Node selected:
┌──────────────────────┐
│ Properties           │
├──────────────────────┤
│ Type: [SQL Query]    │
│ Query: [________]    │
│      [SQL Assist]    │
│ Output: [result_]    │
│ Next: [Node3002 ▼]  │
└──────────────────────┘
```

**Property Types**:
- Text input
- Number input
- Dropdown (select)
- Color picker
- Font selector
- File browser
- Expression builder (special)

## Form Designer (WYSIWYG)

### Canvas Visual
```
┌─────────────────────────────────────────────────┐
│  Toolbar: [Select] [Button] [TextBox] [Grid]   │
├─────────────────────────────────────────────────┤
│                                                 │
│   ┌──────────────────────────────────────┐    │
│   │  Form: frmClientes                   │    │
│   │  ┌────────────────┐                  │    │
│   │  │ Name: [______] │                  │    │
│   │  └────────────────┘                  │    │
│   │  ┌────────────────┐                  │    │
│   │  │ Email: [_____] │                  │    │
│   │  └────────────────┘                  │    │
│   │  [Save] [Cancel]                     │    │
│   └──────────────────────────────────────┘    │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Paleta de Componentes
```
┌──────────────────────────┐
│ Components Palette       │
├──────────────────────────┤
│ 📝 TextBox              │
│ 🔘 Button               │
│ ☑  CheckBox             │
│ 🔽 ComboBox             │
│ 📋 Grid (DataTable)     │
│ 📅 DatePicker           │
│ 📄 Label                │
│ 🖼️ Image                │
│ 📦 Container/Panel      │
│ 📑 TabControl           │
│ 📊 Chart                │
└──────────────────────────┘
```

### Drag & Drop System
**Implementação**:
```javascript
// Component drag from palette
const onDragStart = (e, componentType) => {
  e.dataTransfer.setData('componentType', componentType);
};

// Drop on canvas
const onDrop = (e) => {
  const componentType = e.dataTransfer.getData('componentType');
  const x = e.clientX - canvasRect.left;
  const y = e.clientY - canvasRect.top;
  
  // Create new component
  addComponentToForm({
    type: componentType,
    x: x,
    y: y,
    width: defaultWidths[componentType],
    height: defaultHeights[componentType]
  });
};
```

### Selection & Manipulation
**Funcionalidades**:
- **Single Select**: Click no componente
- **Multi Select**: Ctrl+Click ou Rectangle selection
- **Move**: Drag selected
- **Resize**: Drag handles (8 pontos)
- **Align Tools**: Alinhar esquerda, centro, direita, top, bottom
- **Distribution**: Distribuir horizontal/vertical
- **Z-Order**: Bring to front / Send to back

**Visual Feedback**:
```
Selected component:
┌─────────────────┐
│ □              □│  ← Resize handles
│                 │
│   [Button]      │
│                 │
│ □              □│
└─────────────────┘
  Blue border + handles
```

### Grid & Snap
**Grid Settings**:
- Grid size: 10px (configurável)
- Snap to grid: On/Off
- Show grid: On/Off
- Ruler markers: Top and left

### Layout Modes
1. **Absolute Positioning**: X, Y coordinates
2. **Container-based**: Panels com layout managers
3. **Responsive**: Anchoring (top, left, right, bottom)

## Flow Editor (Action Flow)

### Canvas Infinito
```
        ╔═══════════════════════════════════════╗
        ║  Zoom: [−] 100% [+]   Grid: [☑]     ║
        ╠═══════════════════════════════════════╣
        ║ · · · · · · · · · · · · · · · · · · ║
        ║ ·  ┌─────────┐                    · ║
        ║ ·  │ START   │                    · ║
        ║ ·  └────┬────┘                    · ║
        ║ ·       │                         · ║
        ║ ·       ▼                         · ║
        ║ ·  ┌─────────┐                    · ║
        ║ ·  │SQL Query│                    · ║
        ║ ·  └────┬────┘                    · ║
        ║ ·       │                         · ║
        ║ ·       ▼                         · ║
        ║ ·   ┌───────┐                     · ║
        ║ ·   │  IF?  │                     · ║
        ║ ·   └─┬───┬─┘                     · ║
        ║ ·     │   └──→ [Process]          · ║
        ║ ·     ▼                           · ║
        ║ ·  [End]                          · ║
        ║ · · · · · · · · · · · · · · · · · · ║
        ╚═══════════════════════════════════════╝
```

### Tipos de Nós (Node Types)

#### 1. Categoria: Controle de Fluxo
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  START   │  │   END    │  │   IF?    │
│    🏁    │  │    🏁    │  │    ❓    │
└──────────┘  └──────────┘  └──────────┘
```

#### 2. Categoria: Banco de Dados
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│SQL Query │  │  Insert  │  │  Update  │
│    🗄️    │  │    ➕    │  │    ✏️    │
└──────────┘  └──────────┘  └──────────┘
```

#### 3. Categoria: UI
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│Open Form │  │Show Msg  │  │Set Field │
│    🖼️    │  │    💬    │  │    📝    │
└──────────┘  └──────────┘  └──────────┘
```

#### 4. Categoria: Lógica
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│Calculate │  │  Loop    │  │Transform │
│    🧮    │  │    🔁    │  │    🔄    │
└──────────┘  └──────────┘  └──────────┘
```

#### 5. Categoria: Integração
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│Send Email│  │ Call API │  │Export PDF│
│    📧    │  │    🌐    │  │    📄    │
└──────────┘  └──────────┘  └──────────┘
```

### Menu Radial (Circular Context Menu)
**Ativação**: Click direito no canvas vazio

```
              [Loop]
                |
    [IF] ----  (+)  ---- [SQL]
                |
            [Process]
            
    Circular menu with 8 positions
    Quick access to most-used nodes
```

**Implementação**:
```javascript
const showRadialMenu = (x, y) => {
  const menu = [
    {angle: 0, icon: '🏁', label: 'Start', type: 'start'},
    {angle: 45, icon: '🗄️', label: 'SQL', type: 'sql'},
    {angle: 90, icon: '❓', label: 'If', type: 'if'},
    {angle: 135, icon: '🖼️', label: 'Form', type: 'form'},
    // ... etc
  ];
  
  renderRadialMenu(x, y, menu);
};
```

### Linker de Nós (Connection Lines)
**Smart Routing**: Setas que evitam colisões

```
Node A ──┐
         │  ← Calculates best path
         └──→ Node B
```

**Connection Types**:
- **Success Path**: Linha verde sólida
- **Error Path**: Linha vermelha tracejada
- **Conditional**: Linha com label (Yes/No)

**Visual States**:
```
Normal: ──────────→
Hover:  ━━━━━━━━━━→ (thicker)
Selected: ═══════════→ (blue, thick)
```

### Zoom & Pan
**Controles**:
- Mouse wheel: Zoom in/out
- Middle mouse drag: Pan
- Fit to screen button
- Zoom percentages: 25%, 50%, 75%, 100%, 150%, 200%

### Node Configuration
**Double-click no nó** → Abre modal de configuração

```
┌──────────────────────────────────┐
│ Configure: SQL Query Node        │
├──────────────────────────────────┤
│ Connection: [Database1 ▼]       │
│                                  │
│ Query:                           │
│ ┌──────────────────────────────┐│
│ │SELECT * FROM customers       ││
│ │WHERE active = 1              ││
│ └──────────────────────────────┘│
│ [SQL Assistant]                  │
│                                  │
│ Output Variable: [customers_]    │
│                                  │
│ On Success: [Next Node ▼]       │
│ On Error: [Error Handler ▼]     │
│                                  │
│        [Cancel]  [Save]          │
└──────────────────────────────────┘
```

## Assistente SQL (SQL Assistant)

### Interface Visual
```
┌─────────────────────────────────────────────┐
│ SQL Assistant                               │
├─────────────────────────────────────────────┤
│ Tables:          Fields:          Preview:  │
│ ┌────────────┐  ┌────────────┐  SELECT      │
│ │☑customers  │  │☑id         │    id,       │
│ │☐orders     │  │☑name       │    name,     │
│ │☐products   │  │☐address    │    email     │
│ └────────────┘  │☑email      │  FROM        │
│                 └────────────┘    customers │
│                                  WHERE       │
│ WHERE Conditions:                  active=1  │
│ [Field ▼] [=▼] [Value____]                  │
│ [+ Add Condition]                            │
│                                              │
│ ORDER BY: [name ▼] [ASC ▼]                  │
│                                              │
│          [Cancel]  [Generate SQL]            │
└─────────────────────────────────────────────┘
```

## Expression Builder (Construtor de Expressões)

### Interface
```
┌─────────────────────────────────────────────┐
│ Expression Builder                          │
├─────────────────────────────────────────────┤
│ Result:                                     │
│ ┌─────────────────────────────────────────┐│
│ │ [campo1] + ([campo2] * 1.1)            ││
│ └─────────────────────────────────────────┘│
│                                             │
│ Fields:        Operators:    Functions:    │
│ ┌──────────┐  [  +  ]        ┌──────────┐ │
│ │campo1    │  [  -  ]        │SUM()     │ │
│ │campo2    │  [  *  ]        │AVG()     │ │
│ │campo3    │  [  /  ]        │COUNT()   │ │
│ └──────────┘  [  =  ]        │UPPER()   │ │
│               [  <  ]        │LOWER()   │ │
│               [  >  ]        └──────────┘ │
│                                             │
│ Constants:                                  │
│ ┌─────────────────────────────────────────┐│
│ │ "Text" | 123 | true | false | null     ││
│ └─────────────────────────────────────────┘│
│                                             │
│          [Cancel]  [OK]                     │
└─────────────────────────────────────────────┘
```

## Themes & Styling

### Dark Theme (Default)
```css
:root {
  --bg-primary: #1e1e1e;
  --bg-secondary: #252526;
  --bg-tertiary: #2d2d30;
  --accent: #2ecc71;
  --text-primary: #cccccc;
  --text-secondary: #858585;
  --border: #3e3e42;
}
```

### Component Library
**Material-UI / Tailwind CSS**:
- Buttons: Rounded corners, hover effects
- Inputs: Subtle borders, focus highlights
- Modals: Backdrop blur, shadow effects
- Tooltips: Delayed, positioned

## Keyboard Shortcuts
```
Ctrl+S: Save current
Ctrl+N: New object
Ctrl+O: Open object
Ctrl+W: Close tab
Ctrl+Z: Undo
Ctrl+Y: Redo
Ctrl+C: Copy
Ctrl+V: Paste
Ctrl+X: Cut
Del: Delete selected
F5: Run/Preview
Ctrl+F: Find
```

## State Management

### Frontend State
```javascript
const appState = {
  workspace: {
    openTabs: [],
    activeTab: null,
    leftPanelVisible: true,
    rightPanelVisible: true
  },
  forms: {
    loadedForms: {},
    dirtyForms: []  // unsaved changes
  },
  flows: {
    loadedFlows: {},
    dirtyFlows: []
  },
  selection: {
    selectedComponents: [],
    selectedNodes: []
  },
  clipboard: {
    type: null,
    data: null
  }
};
```

## Real-time Preview
**Live Mode**: Alternar entre Design/Preview

```
[Design Mode]  [Preview Mode]
     ↓              ↓
Edit interface  See as user sees
  + Properties    - Properties panel
  + Grid          - Grid
  + Handles       + Full interaction
```

## Summary

O frontend do Maker AI é:
1. **Uma IDE completa** com múltiplos editores especializados
2. **Altamente visual** com WYSIWYG e canvas interativos
3. **Context-aware** com painéis adaptativos
4. **Produtivo** com shortcuts e assistentes
5. **Profissional** com design consistente e moderno
