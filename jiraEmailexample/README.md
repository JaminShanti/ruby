# Jira Email Example

This script generates a status report from Jira and sends it via email.

## Prerequisites

- Ruby
- Bundler

## Installation

1. Install dependencies from the root directory:
   ```bash
   bundle install
   ```

2. Create a `.env` file based on the `.env.sample` file and add your Jira and Email credentials:
   ```bash
   cp .env.sample .env
   ```

## Usage

Run the script:

```bash
ruby Generate_StatusReport.rb
```
