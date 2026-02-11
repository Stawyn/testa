import pyodbc
from typing import Dict, List, Any, Optional
from app.core.config import settings


class DatabaseConnectionManager:
    """Manages database connections"""
    
    def __init__(self):
        self.connections: Dict[str, pyodbc.Connection] = {}
        self.connection_configs: Dict[str, Dict] = {}
        
        # Add default connection
        self.add_connection('default', {
            'host': settings.DATABASE_HOST,
            'port': settings.DATABASE_PORT,
            'database': settings.DATABASE_NAME,
            'user': settings.DATABASE_USER,
            'password': settings.DATABASE_PASSWORD
        })
    
    def add_connection(self, conn_id: str, config: Dict):
        """Register a new database connection configuration"""
        self.connection_configs[conn_id] = config
    
    def get_connection(self, conn_id: str = 'default') -> pyodbc.Connection:
        """Get or create a database connection"""
        if conn_id not in self.connections or not self._is_connection_alive(conn_id):
            self._create_connection(conn_id)
        return self.connections[conn_id]
    
    def _create_connection(self, conn_id: str):
        """Create a new database connection"""
        config = self.connection_configs[conn_id]
        
        conn_str = (
            f"DRIVER={{ODBC Driver 17 for SQL Server}};"
            f"SERVER={config['host']},{config['port']};"
            f"DATABASE={config['database']};"
            f"UID={config['user']};"
            f"PWD={config['password']}"
        )
        
        self.connections[conn_id] = pyodbc.connect(conn_str)
    
    def _is_connection_alive(self, conn_id: str) -> bool:
        """Check if connection is still alive"""
        try:
            if conn_id in self.connections:
                cursor = self.connections[conn_id].cursor()
                cursor.execute("SELECT 1")
                cursor.close()
                return True
        except:
            return False
        return False
    
    def execute_query(
        self, 
        query: str, 
        params: Optional[List] = None,
        conn_id: str = 'default'
    ) -> List[Dict]:
        """Execute a SELECT query and return results as list of dicts"""
        conn = self.get_connection(conn_id)
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        # Get column names
        columns = [column[0] for column in cursor.description]
        
        # Fetch all rows and convert to dict
        results = []
        for row in cursor.fetchall():
            results.append(dict(zip(columns, row)))
        
        cursor.close()
        return results
    
    def execute_non_query(
        self,
        query: str,
        params: Optional[List] = None,
        conn_id: str = 'default'
    ) -> int:
        """Execute INSERT/UPDATE/DELETE and return affected rows"""
        conn = self.get_connection(conn_id)
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        conn.commit()
        rowcount = cursor.rowcount
        cursor.close()
        return rowcount
    
    def test_connection(self, conn_id: str = 'default') -> bool:
        """Test if connection is working"""
        try:
            conn = self.get_connection(conn_id)
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.close()
            return True
        except Exception as e:
            print(f"Connection test failed: {e}")
            return False
    
    def close_all(self):
        """Close all connections"""
        for conn in self.connections.values():
            try:
                conn.close()
            except:
                pass
        self.connections.clear()


# Global instance
db_manager = DatabaseConnectionManager()
