# Database Schema - Ngo Volunteer Management

## Overview
This document outlines the database schema for the Ngo Volunteer Management application using Firebase Cloud Firestore.

## Collections

### 1. volunteers
Stores information about volunteers.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| name | String | Volunteer's full name |
| email | String | Email address |
| phone | String | Contact phone number |
| address | String | Physical address |
| joinDate | String | Date of joining (ISO format) |
| status | PersonStatus | Current status (active/inactive) |
| assignedAdmin | String | Admin assigned to this volunteer |
| taskIds | List<int> | IDs of assigned tasks |
| tenure | String | Duration of volunteering |
| skills | List<String> | List of skills |
| avatar | String | URL/path to profile image |

### 2. members
Stores information about organization members.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| name | String | Member's full name |
| email | String | Email address |
| phone | String | Contact phone number |
| address | String | Physical address |
| joinDate | String | Date of joining (ISO format) |
| renewalDate | String | Date of membership renewal |
| status | PersonStatus | Current status |
| membershipType | MembershipType | Type of membership |
| taskIds | List<int> | IDs of assigned tasks |
| isPaid | bool | Payment status |
| avatar | String | URL/path to profile image |

### 3. tasks
Stores information about tasks assigned to volunteers/members.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| title | String | Task title |
| description | String | Detailed task description |
| deadline | String | Task deadline (ISO format) |
| assignedToId | int | ID of assigned person |
| assignedToName | String | Name of assigned person |
| assignedToType | AssigneeType | Type (volunteer/member) |
| status | TaskStatus | Current status |
| requiresUpload | bool | Whether task requires file upload |
| createdAt | String | Creation timestamp |
| uploadedImage | String? | URL of uploaded file (if any) |
| submittedAt | String? | Submission timestamp |

### 4. donations
Stores information about donations received.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| donorName | String | Donor's name |
| amount | int | Donation amount |
| date | String | Donation date |
| type | DonationType | Type of donation |
| receiptGenerated | bool | Whether receipt was generated |
| purpose | String | Purpose of donation |
| is80G | bool | Whether eligible for 80G deduction |
| receiptNumber | String? | Receipt number (if generated) |
| razorpayPaymentId | String? | Razorpay payment ID (for online payments) |
| razorpayOrderId | String? | Razorpay order ID |
| paymentStatus | PaymentStatus | Payment status (pending/success/failed) |
| donorEmail | String? | Donor's email address |
| donorPhone | String? | Donor's phone number |

### 5. general_requests
Stores joining letter and certificate requests.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| requestType | GeneralRequestType | Type (joining-letter/certificate) |
| requesterName | String | Name of requester |
| requesterType | String | 'volunteer' or 'member' |
| requestDate | String | Date of request |
| status | RequestStatus | Current status |
| details | String | Additional details |

### 6. mou_requests
Stores Medical Officer Undertaking requests for hospital/medical assistance.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| patientName | String | Patient's name |
| patientAge | int | Patient's age |
| disease | String | Medical condition |
| hospital | String | Hospital name |
| requestDate | String | Date of request |
| status | RequestStatus | Current status |
| requesterName | String | Requester's name |
| phone | String | Contact phone |
| address | String | Patient's address |
| bloodGroup | String | Blood group |

### 7. joining_letter_requests
Stores specific joining letter requests.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| name | String | Requester's name |
| type | JoiningLetterType | Type of joining letter |
| requestDate | String | Date of request |
| status | RequestStatus | Current status |
| tenure | String | Duration requested |
| isNewMember | bool | Whether for new member |
| generatedBy | String? | Admin who generated it |

### 8. documents
Stores information about uploaded documents.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| title | String | Document title |
| category | String | Document category |
| fileType | DocumentFileType | Type of file |
| size | String | File size |
| uploadDate | String | Upload timestamp |

### 9. meetings
Stores information about meetings.

| Field | Type | Description |
|-------|------|-------------|
| id | int | Unique identifier |
| title | String | Meeting title |
| date | String | Meeting date |
| time | String | Meeting time |
| attendees | List<String> | List of attendee names |
| status | MeetingStatus | Current status |
| summary | String? | Meeting summary |
| addedBy | String? | Who added the meeting |

### 10. monthly_donation_points
Stores aggregated monthly donation data for charts.

| Field | Type | Description |
|-------|------|-------------|
| month | String | Month (YYYY-MM format) |
| amount | int | Total donation amount for month |

## Enums

### PersonStatus
- active
- inactive
- pending

### MembershipType
- life
- annual
- patron

### TaskStatus
- pending
- in_progress
- completed
- cancelled

### AssigneeType
- volunteer
- member

### DonationType
- cash
- cheque
- online_transfer
- in_kind

### PaymentStatus
- pending
- success
- failed

### GeneralRequestType
- joining-letter
- certificate

### RequestStatus
- pending
- approved
- rejected
- completed

### JoiningLetterType
- new_member
- renewal
- transfer

### DocumentFileType
- pdf
- image
- document
- spreadsheet

### MeetingStatus
- scheduled
- ongoing
- completed
- cancelled

## Indexes (for Firestore queries)
- volunteers: status
- members: status, membershipType
- tasks: status, assignedToId, assignedToType
- donations: date, type, is80G
- general_requests: requestType, status, requesterType
- mou_requests: status, hospital
- joining_letter_requests: status, type, isNewMember
- documents: category, fileType, uploadDate
- meetings: date, status, attendees
- monthly_donation_points: month (descending)

## Relationships
- Volunteer ↔ Task (one-to-many via taskIds)
- Member ↔ Task (one-to-many via taskIds)
- Task ← Volunteer/Member (many-to-one via assignedToId/Type)
- GeneralRequest ↔ Volunteer/Member (via requesterType and requesterName)
- MouRequest stands alone (medical assistance requests)
- Document stands alone (file repository)
- Meeting stands alone (event scheduling)
- MonthlyDonationPoint stands alone (analytics aggregation)

## Notes
1. All ID fields are integers for simplicity in this mock implementation
2. Date fields are stored as ISO string format for consistency
3. Boolean fields represent binary states
4. List fields store references to other entities by ID
5. String fields with limited options should use enums in application code