# M42-Dev Templates

This directory contains templates used by the m42-dev tool for project and feature initialization.

## Directory Structure

```
templates/
├── feature/           # Feature-specific templates
│   ├── requirements.yaml    # Feature requirements and milestones
│   └── feature-context.md   # Feature context documentation
└── project/           # Project-level templates
    └── project-context-template.md  # Project context documentation
```

## Templates

### Project Templates

#### project-context-template.md
Used when initializing a new project with `m42-dev init-project`. This template helps create comprehensive project documentation covering:
- Technical stack and architecture
- Code organization and conventions
- Development workflow
- Domain concepts
- Quality standards

### Feature Templates

#### requirements.yaml
Created for each new feature with `m42-dev init <feature-id>`. Defines:
- Feature overview and business value
- Functional and non-functional requirements
- Milestone breakdown with implementation checklists
- Acceptance tests
- Parallel execution strategy
- Definition of done

#### feature-context.md
Also created for each new feature. Documents:
- Integration points with existing system
- Domain model specific to the feature
- Technical constraints
- Data model and migration strategy
- Testing requirements
- Deployment and operations considerations

## Template Variables

Some templates use variables that are replaced during creation:
- `{{FEATURE_ID}}` - The feature identifier provided by the user

## Customization

You can customize these templates to match your project's needs:
1. Edit the template files directly
2. Add new sections or remove ones you don't need
3. Adjust the milestone structure to match your workflow
4. Modify checklists to reflect your tech stack

The tool will use your customized templates for all new features and projects.