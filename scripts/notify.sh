#!/bin/bash

# Jenkins Build Notification Script
# Sends notifications to Slack/SNS on build status

set -e

STATUS=${1:-UNKNOWN}
BUILD_NUMBER=${BUILD_NUMBER:-}
BUILD_URL=${BUILD_URL:-}
GIT_COMMIT=${GIT_COMMIT:-}
GIT_BRANCH=${GIT_BRANCH:-}
ENVIRONMENT=${ENVIRONMENT:-dev}

# Colors for console output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Slack Configuration (set via environment variables or Jenkins credentials)
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-}
SLACK_CHANNEL=${SLACK_CHANNEL:-#devops}

# SNS Configuration
SNS_TOPIC_ARN=${SNS_TOPIC_ARN:-}
AWS_REGION=${AWS_REGION:-ap-south-1}

echo -e "${YELLOW}=== Sending Notifications ===${NC}"
echo "Status: $STATUS"
echo "Build: $BUILD_NUMBER"
echo "Environment: $ENVIRONMENT"

# Function to send Slack notification
send_slack_notification() {
    if [ -z "$SLACK_WEBHOOK_URL" ]; then
        echo "Slack webhook not configured, skipping Slack notification"
        return 0
    fi

    local color
    local emoji
    case "$STATUS" in
        SUCCESS)
            color="good"
            emoji="✅"
            ;;
        FAILURE)
            color="danger"
            emoji="❌"
            ;;
        UNSTABLE)
            color="warning"
            emoji="⚠️"
            ;;
        *)
            color="#808080"
            emoji="❓"
            ;;
    esac

    local message_payload=$(cat <<EOF
{
    "channel": "$SLACK_CHANNEL",
    "username": "Jenkins CI/CD",
    "icon_emoji": ":jenkins:",
    "attachments": [
        {
            "fallback": "StreamingApp Build $BUILD_NUMBER - $STATUS",
            "color": "$color",
            "pretext": "$emoji *StreamingApp Build Notification*",
            "title": "Build #$BUILD_NUMBER - $STATUS",
            "title_link": "$BUILD_URL",
            "fields": [
                {
                    "title": "Environment",
                    "value": "$ENVIRONMENT",
                    "short": true
                },
                {
                    "title": "Branch",
                    "value": "$GIT_BRANCH",
                    "short": true
                },
                {
                    "title": "Commit",
                    "value": "${GIT_COMMIT:0:8}",
                    "short": true
                },
                {
                    "title": "Build URL",
                    "value": "$BUILD_URL",
                    "short": true
                }
            ],
            "footer": "StreamingApp CI/CD Pipeline",
            "ts": $(date +%s)
        }
    ]
}
EOF
)

    echo "Sending Slack notification..."
    curl -X POST -H 'Content-type: application/json' \
        --data "$message_payload" \
        "$SLACK_WEBHOOK_URL" \
        || echo "Failed to send Slack notification"
}

# Function to send SNS notification
send_sns_notification() {
    if [ -z "$SNS_TOPIC_ARN" ]; then
        echo "SNS topic not configured, skipping SNS notification"
        return 0
    fi

    local subject="StreamingApp Build #$BUILD_NUMBER - $STATUS ($ENVIRONMENT)"
    local message="
Build Number: $BUILD_NUMBER
Status: $STATUS
Environment: $ENVIRONMENT
Branch: $GIT_BRANCH
Commit: $GIT_COMMIT
Build URL: $BUILD_URL
Timestamp: $(date)
"

    echo "Sending SNS notification..."
    aws sns publish \
        --topic-arn "$SNS_TOPIC_ARN" \
        --subject "$subject" \
        --message "$message" \
        --region "$AWS_REGION" \
        || echo "Failed to send SNS notification"
}

# Function to send Email notification (if configured)
send_email_notification() {
    local recipients=${EMAIL_RECIPIENTS:-}
    
    if [ -z "$recipients" ]; then
        echo "Email recipients not configured, skipping email notification"
        return 0
    fi

    local subject="StreamingApp Build #$BUILD_NUMBER - $STATUS ($ENVIRONMENT)"
    local body="
Build Number: $BUILD_NUMBER
Status: $STATUS
Environment: $ENVIRONMENT
Branch: $GIT_BRANCH
Commit: $GIT_COMMIT
Build URL: $BUILD_URL
Timestamp: $(date)
"

    echo "Sending email notification..."
    # Note: Requires mail command to be available
    if command -v mail &> /dev/null; then
        echo "$body" | mail -s "$subject" "$recipients"
    else
        echo "Mail command not available"
    fi
}

# Send notifications based on build status
case "$STATUS" in
    SUCCESS)
        echo -e "${GREEN}Build Successful!${NC}"
        send_slack_notification
        send_sns_notification
        ;;
    FAILURE)
        echo -e "${RED}Build Failed!${NC}"
        send_slack_notification
        send_sns_notification
        send_email_notification
        ;;
    UNSTABLE)
        echo -e "${YELLOW}Build Unstable!${NC}"
        send_slack_notification
        send_sns_notification
        ;;
    *)
        echo -e "${YELLOW}Unknown status: $STATUS${NC}"
        ;;
esac

echo -e "${GREEN}=== Notification Send Complete ===${NC}"
