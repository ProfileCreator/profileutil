# NOTE: This project was just a proof of concept, and the core functionality has since been implemented in the ProfileKit framework. You can find that project here: [ProfileKit](https://github.com/ProfileCreator/ProfileKit)

# profileutil

Command line tool to show installed configuration profile information.

It parses the `mdmclient installedProfiles` command output to xml to make it machine readable.

It also adds options to filter the profiles you want to return.

Examples filters:

- Profile installation source: Manual or MDM
- Profile installed by a specific UID
- Profile signed/not signed

It also allows to define different output for the matched profiles:

- XML (default)
- Identifier
- UUID

The output from this command contains no payload keys outside of the required profile keys. If you want to see payload information, use the `profiles` command.


## Usage

```shell

	# Filter
	  Use either key/value OR signed

	--key		string	Payload key to match. (Requires --value)
	--value		string	Value to match for Payload Key. (Requires --key)
	--signed	string	(true|false) Only return profiles with selected signing status. (Default true)

	# Output

	--output	string	(xml|identifier|uuid) The output format. (Default xml)
	--first		-	Returns only the first matched profile.


```

## Examples


#### Show all profiles that has a key with the name "Name" and the value for that key "Global Preferences"

```shell
./profileutil --key "Name" --value "Global Preferences"
```

#### Show all profiles that has the "InstallationSource" set to "Manual" and just list all identifiers as output.

```shell
./profileutil --key "InstallationSource" --value "Manual" --output identifier
