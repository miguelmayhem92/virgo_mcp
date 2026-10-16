import os
from mcp.server import MCPServer
# from mcp.server.mcpserver.exceptions import ToolError

from src.utils.sirius import AssetReader


bucket = os.getenv("BUCKET")

mcp = MCPServer("virgo_mcp")

@mcp.tool()
def launch_asset_lambda_execution(asset:str):
    ar = AssetReader(bucket)
    execution_result = ar.launch_sirius_lambda(asset)
    return execution_result

@mcp.resource("tasks://read_asset_sirius/{asset}")
def read_asset_sirius(asset:str)->str:
    """
    read a sirius df and returns last rows of hedge columns as text
    """
    ar = AssetReader(bucket)
    df = ar.sirius_read_csv(asset)
    recordings = ar.produce_text(df, asset)
    averages = ar.mean_probs_to_string(df, asset)
    return recordings + "\n" + averages


@mcp.prompt()
def task_execution_prompt() -> str:
    
    return """
        conditions to launch a lambda execution of a given asset 
            check last time execution using tasks://asset_last_time_execution
            
            
        
        Use the tasks://all resource to access the complete task list."""

@mcp.prompt()
def sirius_analysis_prompt(data_text:str):
    return f"""You are a data analyst. Analyze the daily probability data below.
        Each line gives the probability that the target goes UP and DOWN on a given date.
        "Spread" means (down - up) in percentage points. A positive spread means down is more likely than up.

        DATA (newest first):
        {data_text}

        Answer these three questions using only the data above. Show the numbers you used.

        1. Is the spread reducing?
        Compare the spread (down - up) on the most recent date with the spread about one week earlier (2026-October-08 or nearest) and with the spread at the start of the data. Say "reducing", "widening", or "stable" (stable = change under 1 percentage point), then give the numbers.

        2. Are the up or down probabilities going up or down?
        For each of UP and DOWN, compare the latest value with the 5-day average of the previous 5 days. Say "rising", "falling", or "flat" for each, with the numbers.

        3. Is there any jump to pay attention to?
        Compute the day-to-day change for UP and DOWN. Flag any change of 3 percentage points or more in either direction. List each flagged date, the metric, and the size of the change. If nothing crosses 3 points, say "No significant jumps."

        Format the answer with the headings "1. Spread", "2. Trend", and "3. Jumps". Keep each section under 4 sentences. Do not add information that is not in the data."""

app = mcp.streamable_http_app()