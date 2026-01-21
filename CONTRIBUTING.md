# Contributing to FabricFlow

Thank you for your interest in contributing to FabricFlow! We welcome contributions from the community.

## How to Contribute

1. **Fork the Repository**: Click the "Fork" button at the top right of the repository page.

2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/your-username/ProFabric.git
   cd ProFabric
   ```

3. **Create a Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make Your Changes**: Implement your feature or bug fix.

5. **Test Your Changes**: Ensure all tests pass and add new tests if necessary.

6. **Commit Your Changes**:
   ```bash
   git add .
   git commit -m "Add: description of your changes"
   ```

7. **Push to Your Fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

8. **Create a Pull Request**: Go to the original repository and click "New Pull Request".

## Code Style Guidelines

### Python (Backend)
- Follow PEP 8 style guide
- Use type hints where applicable
- Write docstrings for all functions and classes
- Run `black` for formatting: `black app/`
- Run `flake8` for linting: `flake8 app/`

### Flutter (Frontend)
- Follow official Flutter style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Run `flutter analyze` before committing
- Run `flutter format .` for formatting

## Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters
- Reference issues and pull requests when relevant

Examples:
- `Add: AI design generation endpoint`
- `Fix: Order optimization bug in supply chain routing`
- `Update: Flutter dependencies to latest versions`
- `Docs: Update API documentation for tracking endpoints`

## Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update documentation if you're changing functionality
3. Ensure your code follows the project's coding standards
4. Ensure all tests pass
5. Request review from maintainers

## Reporting Bugs

If you find a bug, please create an issue with:
- Clear title and description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Environment details (OS, browser, versions)

## Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:
- Clear use case
- Expected behavior
- Why this enhancement would be useful
- Any alternative solutions considered

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Assume good intentions

## Questions?

Feel free to open an issue for any questions about contributing!

Thank you for contributing to FabricFlow! 🎉
