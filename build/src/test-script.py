import argparse
import boto3
import subprocess
import sys

#This is a sample only


def main():
    parser = argparse.ArgumentParser(
        description="AWS Utility Script using Boto3 and Argparse"
    )
    parser.add_argument(
        "--aws-version", action="store_true", help="Display AWS CLI version"
    )
    args = parser.parse_args()

    if args.aws_version:
        try:
            result = subprocess.run(
                ["aws", "--version"],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                check=True,
                text=True,
            )
            print(result.stdout.strip())
        except subprocess.CalledProcessError as e:
            print(f"Error executing aws --version: {e.output}", file=sys.stderr)
            sys.exit(1)
        except FileNotFoundError:
            print(
                "AWS CLI not found. Please install AWS CLI and ensure it's in your PATH.",
                file=sys.stderr,
            )
            sys.exit(1)
        return

    try:
        s3 = boto3.client("s3")
        response = s3.list_buckets()
        print("S3 Buckets:")
        for bucket in response.get("Buckets", []):
            print(f" - {bucket['Name']}")
    except Exception as e:
        print(f"Error accessing AWS with boto3: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
