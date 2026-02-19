# Ruby Scripts Collection

This repository contains a collection of Ruby scripts for various purposes, including interacting with APIs like Twitter and Slack, and generating reports from Jira.

## Project Structure

The repository is organized into several subdirectories, each containing a specific script or project:

-   `Scan_Site/`: A skeleton for a Ruby gem to scan websites.
-   `jiraEmailexample/`: A script to generate a weekly status report from Jira and email it.
-   `slackupdates/`: A script to send a message to a Slack channel.
-   `twittertweets/`: A script to post a tweet to Twitter.

Each subdirectory contains its own `README.md` with specific instructions on how to set up and run the script.

## General Setup

### Prerequisites

-   Ruby (version 2.5 or higher recommended)
-   [Bundler](https://bundler.io/)

### Installation

1.  Clone this repository:
    ```bash
    git clone https://github.com/JaminShanti/ruby.git
    cd ruby
    ```

2.  Install the required gems for all projects using the top-level `Gemfile`:
    ```bash
    bundle install
    ```
    This will install all dependencies needed for the scripts in the subdirectories.

## Usage

For detailed instructions on how to configure and run each script, please refer to the `README.md` file within its respective subdirectory:

-   [Scan_Site/README.md](./Scan_Site/README.md)
-   [jiraEmailexample/README.md](./jiraEmailexample/README.md)
-   [slackupdates/README.md](./slackupdates/README.md)
-   [twittertweets/README.md](./twittertweets/README.md)

Most scripts require you to create a `.env` file from the provided `.env.sample` and fill in your credentials.

## Contributing

Contributions are welcome! Please feel free to submit a pull request.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create a new Pull Request.

## License

This project is licensed under the MIT License.
