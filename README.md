# GitHub Organization Reports

This was adapted from a [gist](https://gist.github.com/jdennes/11404512) by user @[jdennes](https://github.com/jdennes).

It is a very crude way to run a very loose audit against your GitHub organizations users (organization members *and* collaborators) and discover their active/inactive state. I believe that this is a feature in GitHub Enterprise that, for whatever reason, to my knowledge, doesn't exist for a GitHub organizations.

## What does it do?

It pulls down all of your orgainzations members and repositories. It then analyzes repository events and correlates them back to your users. It updates 2 pertinent fields: `active` state (`last_activity >= CUTOFF`, in days) and `last_activity` of the organization repository event for that user. It dumps all of this information in to a CSV.

## Set up

Clone the repository

```bash
$ git clone https://github.com/jsimpson/github-organization-reports.git; cd github-organization-reports
```

Install Octokit

```bash
$ bundle install
```

Configure the script

 * Set `ORGANIZAION` to your organization name.

 * Set `CUTOFF` appropriately.

 * Get a GitHub personal access token.

## Execute

```bash
$ OCTOKIT_ACCESS_TOKEN=<yourtoken> bundle exec ruby organization-reports.rb
$ cat report.csv
```
