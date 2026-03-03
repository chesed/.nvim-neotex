# MCP Server Integration for File Conversion

## Available MCP Servers

### markitdown-mcp

Wraps Microsoft's markitdown library for MCP access.

```json
{
  "mcpServers": {
    "markitdown": {
      "command": "uvx",
      "args": ["markitdown-mcp"]
    }
  }
}
```

### mcp-pandoc

Wraps pandoc for universal format conversion.

```json
{
  "mcpServers": {
    "pandoc": {
      "command": "uvx",
      "args": ["mcp-pandoc"]
    }
  }
}
```

## MCP vs CLI Decision

- Use MCP when: Running in MCP-enabled environment
- Use CLI when: MCP unavailable or need specific flags
