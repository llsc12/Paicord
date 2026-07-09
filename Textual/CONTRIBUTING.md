# Contributing to Textual

Thank you for your interest in contributing to Textual! We welcome contributions from the community and are grateful for any help you can provide.

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How to Contribute

### Reporting Bugs

Before submitting a bug report:
- Check the existing issues to avoid duplicates
- Verify you're using the latest version of Textual

When creating a bug report, include:
- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- Code samples or minimal reproduction cases
- Screenshots or videos if applicable
- Your environment (Xcode version, OS version, device/simulator)

### Suggesting Enhancements

We welcome feature requests and enhancement suggestions! Before submitting:
- Check existing issues for similar suggestions
- Consider if the feature aligns with Textual's core goals

When proposing an enhancement:
- Provide a clear and descriptive title
- Explain the problem you're trying to solve
- Describe your proposed solution
- Include code examples or mockups if applicable
- Discuss any alternative solutions you've considered

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Set up your development environment**:
   - Open `Textual.xcworkspace` at the repository root
   - The workspace includes both the library source and the demo app
3. **Make your changes**:
   - Write clear, self-documenting code
   - Add tests for new functionality
   - Update documentation as needed
   - Ensure the demo app still builds and runs
4. **Test your changes**:
   - Run the test suite and verify all tests pass
   - Build and run the demo app in `Examples/TextualDemo`
   - Test on multiple platforms (iOS, macOS, visionOS) if applicable
5. **Commit your changes** with a descriptive commit message (see style guide below)
6. **Push to your fork** and submit a pull request to the `main` branch

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/gonzalezreal/textual.git
   cd textual
   ```

2. Open the workspace:
   ```bash
   open Textual.xcworkspace
   ```

3. Build and run the demo app to verify your setup

## Style Guides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Keep the first line concise (50 characters or less)
- Reference issues and pull requests where appropriate
- Use the body to explain what and why, not how

Examples:
- `Add support for custom list markers`
- `Fix text selection in nested code blocks`
- `Improve performance of inline attachment resolution`

### Swift Code Style

- Follow Swift API Design Guidelines
- Use clear, descriptive names for types, methods, and variables
- Prefer clarity over brevity
- Use SwiftUI's declarative style and composition patterns
- Keep view bodies focused and extract complex logic into separate methods or types
- Document public APIs with clear, helpful comments
- Use `// MARK:` comments to organize code into logical sections

### Testing

- Write tests for new functionality
- Ensure existing tests continue to pass
- Focus on testing public APIs and observable behavior
- Include edge cases and error conditions
- Keep tests focused and independent

### Documentation

- Update the README if you add user-facing features
- Document public APIs with clear descriptions and examples
- Include code examples in documentation when helpful
- Update the demo app to showcase new features

## Additional Notes

### Issue Labels

We use labels to categorize issues and pull requests:
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed

### Questions?

If you have questions about contributing, feel free to:
- Open an issue with your question
- Start a discussion in the repository
- Review existing issues and pull requests for examples

## Recognition

Contributors are recognized in the project's commit history and release notes. Significant contributions may be highlighted in the README.

---

Thank you for contributing to Textual! Your efforts help make this library better for everyone.
