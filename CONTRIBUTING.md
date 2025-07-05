# Contributing to M42 Dev Tool

Thank you for your interest in contributing to the M42 Dev Tool! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Respect differing viewpoints and experiences

## How to Contribute

### Reporting Issues

1. **Check existing issues** to avoid duplicates
2. **Use issue templates** when available
3. **Provide detailed information**:
   - Tool version
   - Operating system
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages or logs

### Suggesting Features

1. **Open a discussion** first for major features
2. **Describe the problem** you're trying to solve
3. **Propose a solution** with examples
4. **Consider edge cases** and backwards compatibility

### Contributing Code

#### Setup Development Environment

```bash
# Fork and clone the repository
git clone https://github.com/Mission42-ai/m42-dev.git
cd m42-dev

# Create a feature branch
git checkout -b feature/your-feature-name

# Make your changes
# Test your changes
# Commit and push
```

#### Development Guidelines

1. **Follow existing patterns**:
   - Bash style guide for scripts
   - YAML structure for configurations
   - Markdown formatting for documentation

2. **Write clear commit messages**:
   ```
   feat: Add support for custom templates
   
   - Allow users to define custom requirement templates
   - Add template validation
   - Update documentation
   
   Fixes #123
   ```

3. **Test your changes**:
   - Test with different project types
   - Verify bash script changes on Linux/macOS
   - Check YAML parsing with both yq and manual review

4. **Update documentation**:
   - README.md for new features
   - SETUP_GUIDE.md for configuration changes
   - Add examples if introducing new concepts

#### Pull Request Process

1. **Before submitting**:
   - [ ] Test on clean project
   - [ ] Update documentation
   - [ ] Add example if applicable
   - [ ] Check for breaking changes

2. **PR description should include**:
   - What problem does this solve?
   - How does it work?
   - Any breaking changes?
   - Testing performed

3. **Review process**:
   - PRs require at least one review
   - Address feedback constructively
   - Keep PRs focused and small

### Testing Contributions

Help us test the tool:
1. Try it on different project types
2. Test edge cases
3. Report unexpected behavior
4. Suggest improvements to error messages

### Documentation Contributions

Good documentation is crucial:
1. Fix typos and clarify confusing sections
2. Add examples for complex features
3. Translate documentation
4. Create video tutorials or blog posts

## Development Practices

### Bash Script Guidelines

```bash
# Use set -e for error handling
set -e

# Quote variables
echo "Processing: ${FEATURE_ID}"

# Use functions for reusability
validate_feature_id() {
    local feature_id="$1"
    [[ "$feature_id" =~ ^FEAT-[0-9]+ ]] || return 1
}

# Add helpful error messages
if ! validate_feature_id "$FEATURE_ID"; then
    echo "Error: Invalid feature ID format. Expected: FEAT-XXX" >&2
    exit 1
fi
```

### YAML Structure

```yaml
# Use clear, consistent structure
feature:
  id: "FEAT-XXX"          # Always quote IDs
  name: "Clear Name"      # Descriptive names
  
milestones:
  - id: "M1"
    name: "Milestone Name"
    # Group related items
    implementation_checklist:
      category:
        "Task description": "status"
```

### Error Handling

1. **Validate inputs** early
2. **Provide helpful error messages**
3. **Handle edge cases gracefully**
4. **Log errors appropriately**

## Release Process

1. **Version numbering**: Semantic versioning (MAJOR.MINOR.PATCH)
2. **Changelog**: Update CHANGELOG.md with all changes
3. **Testing**: Full test suite must pass
4. **Documentation**: Ensure docs are up-to-date

## Getting Help

- **Discord**: [Join our community](https://discord.gg/m42-dev)
- **Discussions**: Use GitHub Discussions for questions
- **Email**: support@mission42.ai

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Given credit in documentation

## Areas Needing Help

Current priorities:
1. **Windows support** (PowerShell version)
2. **More templates** for different architectures
3. **Integration tests**
4. **Performance optimization** for large projects
5. **Plugin system** for extensibility

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to make autonomous development better for everyone! 🚀