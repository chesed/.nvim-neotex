---
name: skill-memory
description: Memory vault management - create, search, classify, and index memories. Invoke for /learn command memory operations.
allowed-tools: Bash, Grep, Read, Write, Edit, AskUserQuestion
---

# Memory Skill (Direct Execution)

Direct execution skill for memory vault management. Handles memory creation, similarity search, classification, and index maintenance.

**Key behavior**: Users always see memory preview and options BEFORE any files are created.

## Context References

Reference (do not load eagerly):
- Path: `@.opencode/memory/30-Templates/memory-template.md` - Memory template
- Path: `@.opencode/memory/20-Indices/index.md` - Memory index
- Path: `@.opencode/context/project/memory/learn-usage.md` - Usage guide

---

## Execution Modes

### Standard Mode: `mode=standard`

Add text or file content as memory.

### Task Mode: `mode=task`

Review task artifacts and create classified memories.

---

## Standard Mode Execution

### Step 1: Parse Input

Extract input type:

```bash
# Determine if input is file or text
if [ -f "$input" ]; then
  content=$(cat "$input")
  source="file: $input"
else
  content="$input"
  source="user input"
fi
```

### Step 2: Generate Memory ID

```bash
# Get today's date and count existing memories
today=$(date +%Y-%m-%d)
count=$(ls -1 .opencode/memory/10-Memories/MEM-${today}-*.md 2>/dev/null | wc -l)
next_num=$(printf "%03d" $((count + 1)))
memory_id="MEM-${today}-${next_num}"
```

### Step 3: Generate Title

Extract first line or first 60 characters as title:

```bash
title=$(echo "$content" | head -1 | cut -c1-60)
# Remove any leading punctuation or whitespace
title=$(echo "$title" | sed 's/^[[:space:]#*-]*//')
```

### Step 4: Search Similar Memories

Check for similar existing memories:

```bash
# Extract keywords from content (significant words)
keywords=$(echo "$content" | tr ' ' '\n' | grep -E '^[a-zA-Z]{4,}$' | sort -u | head -10)

# Search existing memories
for keyword in $keywords; do
  grep -l -i "$keyword" .opencode/memory/10-Memories/*.md 2>/dev/null
done | sort | uniq -c | sort -rn | head -3
```

### Step 5: Present Preview with Options

Display preview and options via AskUserQuestion:

```json
{
  "question": "What would you like to do with this memory?",
  "header": "Memory Preview",
  "multiSelect": true,
  "options": [
    {
      "label": "Add as new memory",
      "description": "Create new file: {memory_id}"
    },
    {
      "label": "Update existing similar memory",
      "description": "Append to: {similar_memory_file}"
    },
    {
      "label": "Edit content before saving",
      "description": "Modify content first"
    },
    {
      "label": "Skip - don't save",
      "description": "Cancel without saving"
    }
  ]
}
```

**Display preview before options**:
```
Memory Preview:
---------------------------------------------
ID: {memory_id}
Title: {title}
Source: {source}
Date: {today}

Content Preview (first 300 chars):
{content_preview}
---------------------------------------------

Similar Memories Found:
- {similar_memory_1}
- {similar_memory_2}
```

### Step 6: Handle User Selection

#### Add as new memory

```bash
# Generate slug from title
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | cut -c1-50)
filename="MEM-${today}-${next_num}-${slug}.md"
filepath=".opencode/memory/10-Memories/${filename}"

# Create memory file from template
cat > "$filepath" << EOF
---
id: ${memory_id}
title: "${title}"
date: ${today}
tags:
source: "${source}"
---

${content}
EOF
```

#### Update existing

```bash
# Append to selected memory with update marker
cat >> "$selected_memory" << EOF

---

## Update (${today})

${content}
EOF
```

#### Edit content

Open content in a buffer for editing, then proceed with add/update.

#### Skip

Exit gracefully without changes.

### Step 7: Update Index

Add link to new memory in index.md:

```bash
# Append to index
echo "- [${title}](../10-Memories/${filename})" >> .opencode/memory/20-Indices/index.md
```

### Step 8: Return Result

```json
{
  "status": "completed",
  "mode": "standard",
  "memory_id": "{memory_id}",
  "actions_taken": ["added"],
  "file_path": "{filepath}"
}
```

---

## Task Mode Execution

### Step 1: Locate Task Directory

```bash
# Find task directory (handles zero-padded format)
task_num=$task_number
padded_num=$(printf "%03d" $task_num)
task_dir=$(ls -d specs/${padded_num}_* 2>/dev/null | head -1)

if [ -z "$task_dir" ]; then
  # Try unpadded
  task_dir=$(ls -d specs/${task_num}_* 2>/dev/null | head -1)
fi

if [ -z "$task_dir" ]; then
  echo "Task directory not found: specs/${padded_num}_*"
  exit 1
fi
```

### Step 2: Scan Artifacts

```bash
# Find all artifact files
artifacts=$(find "$task_dir" -type f -name "*.md" | sort)

if [ -z "$artifacts" ]; then
  echo "No artifacts found for task ${task_number}"
  exit 1
fi
```

### Step 3: Present Artifact List

Display numbered list via AskUserQuestion:

```json
{
  "question": "Select artifacts to review for memory extraction:",
  "header": "Task Artifacts",
  "multiSelect": true,
  "options": [
    {
      "label": "{artifact_1_name}",
      "description": "{artifact_1_path}"
    },
    ...
  ]
}
```

### Step 4: Review Each Selected Artifact

For each selected artifact:

1. Read content
2. Display content preview (first 500 chars)
3. Present classification options

```json
{
  "question": "Classify this artifact for memory extraction:",
  "header": "Classification: {artifact_name}",
  "multiSelect": false,
  "options": [
    {
      "label": "[TECHNIQUE]",
      "description": "Reusable method or approach"
    },
    {
      "label": "[PATTERN]",
      "description": "Design or implementation pattern"
    },
    {
      "label": "[CONFIG]",
      "description": "Configuration or setup knowledge"
    },
    {
      "label": "[WORKFLOW]",
      "description": "Process or procedure"
    },
    {
      "label": "[INSIGHT]",
      "description": "Key learning or understanding"
    },
    {
      "label": "[SKIP]",
      "description": "Not valuable for memory"
    }
  ]
}
```

### Step 5: Create Classified Memories

For each non-skipped artifact:

```bash
# Generate memory with classification tag
category=$selected_classification
today=$(date +%Y-%m-%d)

cat > ".opencode/memory/10-Memories/${filename}" << EOF
---
id: ${memory_id}
title: "${title}"
date: ${today}
tags: ${category}, task-${task_number}
source: "Task ${task_number} - ${artifact_path}"
---

# ${title}

**Category**: ${category}
**Source**: Task ${task_number} - ${artifact_path}
**Date**: ${today}

${extracted_content}
EOF
```

### Step 6: Update Index

Add all new memories to index with category grouping.

### Step 7: Return Result

```json
{
  "status": "completed",
  "mode": "task",
  "artifacts_reviewed": [...],
  "memories_created": [
    {"id": "MEM-...", "category": "[PATTERN]", "path": "..."},
    ...
  ]
}
```

---

## Error Handling

### No Content Provided

```
Usage: /learn <text or file path> OR /learn --task N
```

### File Not Found

```
File not found: {path}
```

### Task Directory Not Found

```
Task directory not found: specs/{NNN}_*
```

### User Cancels

Exit gracefully:
```
Memory operation cancelled. No files created.
```

### All Artifacts Skipped

```
No memories created (all artifacts classified as SKIP)
```

---

## Git Commit (Postflight)

After successful memory creation:

```bash
git add .opencode/memory/
git commit -m "memory: add ${memory_id}

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```
