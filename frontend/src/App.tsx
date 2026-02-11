import { ThemeProvider, createTheme, CssBaseline } from '@mui/material';

const darkTheme = createTheme({
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

function App() {
  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <div style={{ padding: '20px' }}>
        <h1>Visual3 Low-Code Platform</h1>
        <p>Sistema inicializado com sucesso!</p>
        <p>Backend API: {import.meta.env.VITE_API_URL || 'http://localhost:8000'}</p>
      </div>
    </ThemeProvider>
  );
}

export default App;
