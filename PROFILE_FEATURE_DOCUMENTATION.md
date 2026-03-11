# Profile Feature Documentation - LittleBees Web App

## Overview

This document describes the newly implemented **Profile Page** feature for the LittleBees (KinderSpace) web application. The profile page is a comprehensive, role-based user interface that adapts to three main user roles: **Director**, **Teacher**, and **Parent**.

---

## Feature Location

**Route:** `/profile`

**Access:** Available from the top navigation bar dropdown menu under "Mi Perfil"

---

## Architecture

### Folder Structure

```
apps/web/src/
├── app/(dashboard)/
│   └── profile/
│       └── page.tsx                 # Main profile page
├── components/
│   ├── profile/
│   │   ├── index.ts                 # Barrel export
│   │   ├── profile-header.tsx       # Profile header component
│   │   ├── stats-card.tsx           # Reusable stats card
│   │   ├── quick-actions.tsx        # Quick actions component
│   │   ├── teacher-profile.tsx      # Teacher-specific content
│   │   ├── parent-profile.tsx       # Parent-specific content
│   │   ├── director-profile.tsx     # Director-specific content
│   │   ├── activity-tab.tsx         # Activity history tab
│   │   ├── notifications-tab.tsx    # Notifications tab
│   │   └── security-tab.tsx         # Security settings tab
│   └── ui/
│       └── switch.tsx               # New Switch component (Radix UI)
```

---

## Components

### 1. Main Profile Page (`page.tsx`)

The main page component that:
- Detects user role from auth context
- Renders appropriate role-specific profile
- Manages tab navigation (Profile, Activity, Notifications, Security)
- Shows loading state while fetching user data

### 2. ProfileHeader

**Purpose:** Displays user's basic information consistently across all roles

**Features:**
- Large avatar with initials fallback
- Full name and role badge with color coding
- Email, phone, and organization info
- Edit profile button
- Responsive layout (mobile/desktop)

**Role Colors:**
- Super Admin: Purple
- Director: Blue
- Admin: Indigo
- Teacher: Green
- Parent: Orange

### 3. StatsCard

**Purpose:** Reusable component for displaying metrics

**Props:**
- `title`: Metric name
- `value`: Metric value (number or string)
- `icon`: Lucide icon component
- `description`: Optional description
- `trend`: Optional trend indicator (positive/negative percentage)
- `color`: Color theme (blue, green, orange, purple, red)

### 4. QuickActions

**Purpose:** Grid of action buttons for common tasks

**Props:**
- `title`: Section title (default: "Acciones Rápidas")
- `actions`: Array of action objects with label, icon, onClick, and variant

---

## Role-Specific Profiles

### Teacher Profile

**Information Displayed:**
- Assigned classroom
- Number of children assigned
- Work schedule
- Working days

**Metrics:**
- Photos uploaded this week (with trend)
- Daily reports submitted this month (with trend)
- Messages with parents this week
- Activities created this month

**Quick Actions:**
- Create Activity
- Upload Photos
- Write Daily Report
- Open Messages
- View Children Progress
- View Children List

### Parent Profile

**Information Displayed:**
- Personal relationship (Mom/Dad/Guardian)
- Emergency contact
- Address and city

**Children Section:**
- Card for each child showing:
  - Name and age
  - Assigned classroom
  - Teacher name
  - Avatar
- Click to view child details

**Summary Cards:**
- Next school event
- Payment status (color-coded)
- Latest development report
- Latest photo uploaded

**Quick Actions:**
- Chat with Teacher (primary action)
- View Gallery
- Pay Tuition
- View Calendar
- View Development Progress

### Director Profile

**Center Information:**
- Center name
- Position (Director General)
- Years of experience
- License number

**Center Metrics:**
- Total children (with trend)
- Total teachers
- Total parents
- Total classrooms

**Daily Status:**
- Attendance percentage today
- Pending payments
- Photos uploaded today (with trend)
- Active chats

**Quick Actions:**
- Add Child (primary action)
- Add Teacher
- View Reports
- Manage Finances
- System Settings
- View Messages

---

## Tabs

### Profile Tab
Shows role-specific content (described above)

### Activity Tab
- Recent activity feed
- Activity types: photos, reports, messages, other
- Color-coded icons
- Timestamps
- Empty state when no activity

### Notifications Tab
- List of notifications with read/unread status
- Color-coded by type (info, success, warning)
- Mark all as read button
- Individual delete buttons
- Unread count indicator
- Empty state

### Security Tab

**Security Settings:**
- Change password
- Two-factor authentication (2FA) toggle
- Active sessions management

**Notification Preferences:**
- Email notifications toggle
- Push notifications toggle

**Danger Zone:**
- Delete account (destructive action)

---

## Technical Details

### Dependencies Added
- `@radix-ui/react-switch` (v1.2.6) - For toggle switches in security settings

### Existing Dependencies Used
- `@radix-ui/react-tabs` - Tab navigation
- `@radix-ui/react-avatar` - User avatars
- `lucide-react` - Icons
- `next/navigation` - Routing
- `date-fns` - Date formatting

### State Management
- Uses `useAuth` hook for user context
- Client-side components with React hooks
- Mock data for demonstration (ready for API integration)

### Styling
- TailwindCSS utility classes
- Shadcn/UI component library
- Responsive design (mobile-first)
- Color-coded role badges and metrics
- Consistent spacing and typography

---

## Mock Data

Currently using mock data for:
- Teacher classroom assignments and metrics
- Parent children list and summaries
- Director center metrics and daily status
- Activity history
- Notifications

**Ready for API Integration:** All components are structured to easily replace mock data with API calls.

---

## Navigation Updates

### Top Bar (`top-bar.tsx`)
- Added `/profile` to page titles mapping
- Made "Mi Perfil" dropdown item functional
- Added router navigation on click

### Accessibility
- Profile page now accessible from user dropdown menu
- Clear visual feedback on active tab
- Keyboard navigation support (via Radix UI)

---

## Responsive Design

**Mobile (< 1024px):**
- Single column layout
- Stacked cards
- Full-width components
- Touch-friendly buttons

**Desktop (≥ 1024px):**
- Multi-column grid layouts
- Optimized spacing
- Larger avatars and icons

---

## Future Enhancements

1. **API Integration:**
   - Connect to backend endpoints for real data
   - Implement edit profile functionality
   - Add real-time notifications

2. **Features:**
   - Profile picture upload
   - Advanced filtering in activity tab
   - Export reports
   - Notification preferences per type

3. **Performance:**
   - Implement pagination for activity feed
   - Add infinite scroll for notifications
   - Optimize image loading

---

## Testing Recommendations

1. Test with different user roles (Teacher, Parent, Director)
2. Verify responsive layout on mobile/tablet/desktop
3. Test tab navigation and state persistence
4. Verify all quick action buttons navigate correctly
5. Test with users having multiple children (Parent role)
6. Verify empty states display correctly

---

## Usage Example

```typescript
// The profile page automatically detects the user's role
// and renders the appropriate content

// Access via:
// 1. Top navigation dropdown → "Mi Perfil"
// 2. Direct URL: /profile

// The page will show:
// - ProfileHeader (all roles)
// - Role-specific profile content
// - 4 tabs: Profile, Activity, Notifications, Security
```

---

## Component Import Example

```typescript
import {
  ProfileHeader,
  StatsCard,
  QuickActions,
  TeacherProfile,
  ParentProfile,
  DirectorProfile,
} from '@/components/profile';
```

---

## Status

✅ **Completed:**
- Main profile page with routing
- All role-specific profiles
- Reusable components (StatsCard, QuickActions)
- All 4 tabs (Profile, Activity, Notifications, Security)
- Navigation integration
- Responsive design
- Mock data for demonstration

🔄 **Ready for:**
- API integration
- Real data connection
- User testing
- Production deployment

---

## Notes

- All components use TypeScript for type safety
- Components follow Next.js App Router conventions
- Server components used where possible
- Client components marked with 'use client'
- Follows existing design system and patterns
- Mock data is realistic and comprehensive
