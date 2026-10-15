from mcp.server import MCPServer
from mcp.server.mcpserver.exceptions import ToolError


mcp = MCPServer("virgo_mcp")

@mcp.tool()
def launch_asset_lambda_execution(asset:str):
    """
    execute sirius edge lambda
    """
    pass

@mcp.resource("tasks://read_asset_sirius")
def read_asset_sirius(asset:str)->str:
    """
    read a sirius df and returns last rows of hedge columns as text
    """
    pass


@mcp.prompt()
def task_execution_prompt() -> str:
    
    return """
        conditions to launch a lambda execution of a given asset 
            check last time execution using tasks://asset_last_time_execution
            
            
        
        Use the tasks://all resource to access the complete task list."""


app = mcp.streamable_http_app()