@ECHO OFF
REM See https://gist.github.com/sneak/740dfe13f81deafbef7a

ECHO Removing current environment variables
SET AWS_ACCESS_KEY_ID=
SET AWS_SECRET_ACCESS_KEY=
SET AWS_SESSION_TOKEN=
SET AWS_REGION=us-west-1

REM Replace ... with proper values
SET ROLE=DeveloperRole
SET IAMUSER=CompanyUserName
SET IAM_ACCOUNT=...
SET ACCOUNT=52222222222222222012
SET REGION=us-west-1
SET ROLEARN=arn:aws:iam::%ACCOUNT%:role/%ROLE%
REM SET MFAARN=arn:aws:iam::%IAM_ACCOUNT%:mfa/%IAMUSER%

SET TEMP_FILE=%TEMP%\aws_assume_role.txt

REM SET /P MFACODE=Enter MFA token:

FOR /F "tokens=2-4 skip=3" %%i IN ('aws --output table --query Credentials^
    --region %REGION% sts assume-role ^
    --role-arn %ROLEARN% ^
    --role-session-name assumption-%IAMUSER% ) DO (
  IF /I "%%i" == "AccessKeyId" SET AWS_ACCESS_KEY_ID=%%k
  REM Note that SecretAccessKey has the | separator inside its token, so the tokens are offset by one
  IF /I "%%i" == "SecretAccessKey|" SET AWS_SECRET_ACCESS_KEY=%%j
  IF /I "%%i" == "SessionToken" SET AWS_SESSION_TOKEN=%%k
)

IF /I %AWS_ACCESS_KEY_ID% == "" (
  ECHO "Failure"
  EXIT 129
)

ECHO Done
