# CrossAccountSetup

This repo addresses a gap in AWS provided solution : https://github.com/awslabs/aws-cross-account-manager. While AWS solution works for GUI users, it does not for developers who need CLI access. Solution is free, except for the use of a s3 bucket to host the login page website.

## New Developer

- turn on FileVault : <https://support.apple.com/en-nz/HT204837>
- `brew update`
- `brew install awscli jq curl bash coreutils`
- `sudo gem install bundler`.
- check mail for `firstname.lastname@company.com-credentials.csv` file.
- download and rename to `credentials.csv`
- clone this repo
- `bundle install` in the directory
- put the `credentials.csv` in this working directory.
- run `ruby bootstrap-dev.rb`
- follow rest of the instructions on screen.

### Auth.aws shell file

#### auth

Description : Function does auth with aws. Usage : `auth env-name role-name [123456]`

- `auth` prints: roles / environments available
- `auth legacy DeveloperRole` login with ExpiryTime displayed
- `auth legacy AdminRole 123456` login with MFA requiring role
- `auth dev dev` - shortcut to DevelomentDeveloperRole

#### Set Default AWS Environment
Setting the following variable in your `.bashrc` or `.zshrc` file will make it so that you can by default use a specific ENV as default with `aws` cli tool.

`export AWS_PROFILE=DevelomentDeveloperRole`


#### deauth

Description : unsets ENV variables that allow auth with AWS to work. use this to get std `aws` cli behaviour.

#### role_status

Description : shows time left of the current terminal aws authenticated session.

#### Keeping updated

- run `git pull`
- run `./update-dev.sh`

#### MFA / 2FA Setup

If the role you're trying to use requires 2FA/MFA authentication, you need to auth using something like `auth legacy AdminRole`.

## Admin Workflow : development

- `bundle install`
- modify `accounts.json` with account information.
- run `./bootstrap-children.sh`
- run `./bootstrap-parent.sh`
- run `./update-children.sh` to update all child accounts. USES: aws roles in child accounts to perform tasks

## Admin Workflow : Adding and Editing Users

- login to iam website : <https://company-iam.signin.aws.amazon.com/console>
- create and assign users to groups ( max 10 )
- Admin User Groups : [IAMAdmin, IAMUser, (legacy|production|staging|development)AdminRole]
- Developers Groups : [IAMUser, (legacy|production|staging|development)DeveloperRole]

## Guidelines

- never give out `AdminRole` to developers. If you need a very permissive Developer role consult with me : `imran@imra.nz`.
