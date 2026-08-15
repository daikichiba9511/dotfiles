#!/usr/bin/env python3

import argparse
import sys

from kaggle.api.kaggle_api_extended import KaggleApi


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Print the original HTML body for one public Kaggle discussion topic."
    )
    parser.add_argument("--topic-id", required=True, type=int)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    api = KaggleApi()
    api.authenticate()
    topic, _, _ = api.forums_topic_show(args.topic_id, page_size=1)
    if topic is None or not topic.content:
        raise SystemExit(f"Kaggle topic {args.topic_id} did not return an original HTML body")
    sys.stdout.write(topic.content)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
