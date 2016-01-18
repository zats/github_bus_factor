# GitHub Bus Factor

> More meaningful statistics for GitHub projects than just stars.

![](https://raw.githubusercontent.com/zats/github_bus_factor/master/README/screenshot.png)

    $ gem install github_bus_factor

# Usage

You will need to create a GitHub access token. Head over to https://github.com/settings/tokens and create a new one, call the app `GitHub Score` and copy the token.

To fetch a report for a particular repository

	$ github_bus_factor octokit/octokit.rb

First time you call it, it will prompt you to provide the token you just created.

To remove the token
	
	$ github_bus_factor logout

If you ever forget what each line of the report means, run

	$ github_bus_factor about


# Report

| 🙂 | Description |
| :--: | :-- |
| 🍴 | **Forks**. Might mean people planning are fixing bugs or adding features. |
| 🔭 | **Watchers**. Shows number of people interested in project changes. |
| 🌟 | **Stars**. Might mean it is a good project or that it was featured in a mailing list. Some people use 🌟 as a "Like". |
| 🗓 | **Age**. Mature projects might mean battle tested project. Recent pushes might mean project is actively maintained. |
| 🍻 | **Pull Requests**. Community contributions to the project. Many closed PRs usually is a good sign, while no PRs usual is bad. |
| 🛠 | **Refactoring**. Balance between added and deleted code. Crude value not including semantic understanding of the code. |
| 📦 | **Releases**. Might mean disciplined maintainer. Certain dependency managers rely on releases to be present. |
| 🚌 | **Bus factor**. Chances of the project to become abandoned once current collaborators stop updating it. The higher - the worse. |

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

![](https://raw.githubusercontent.com/zats/github_bus_factor/master/README/NeoNacho.png)