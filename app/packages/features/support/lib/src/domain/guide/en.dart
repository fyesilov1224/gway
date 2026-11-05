import '../guide.dart';

// English translation of tr.dart; keep chapters, topics, steps and notes in step with it.

const guideEn = <GuideChapter>[
  GuideChapter(
    id: 'start',
    title: 'Getting started',
    summary: 'Signing up, signing in, verification and finding your way around.',
    topics: [
      GuideTopic(
        'What is GWAY?',
        intro: 'GWAY is a social platform that brings together every kind of community: hiking, running, cycling, music, '
            'nature, sports, art and more. You join groups, go to events, chat in live audio rooms and meet new people.',
        notes: [
          'GWAY is open to people aged 18 and over.',
          'The app works on phones (Android, iOS) and in a web browser; your account is the same everywhere.',
        ],
      ),
      GuideTopic(
        'Creating an account',
        steps: [
          'On the sign-in screen, tap "Sign up".',
          'Enter your email address and a password. You can also sign up with Google or Apple.',
          "If you signed up with email, tap the verification link sent to your inbox. You can't sign in until your email is verified.",
          'After you sign in, the app takes you through security verification, accepting the legal documents, your date of birth and creating your profile.',
        ],
        tip: "If the verification email hasn't arrived, check your spam folder.",
      ),
      GuideTopic(
        'I forgot my password',
        steps: [
          'On the sign-in screen, tap "Forgot password".',
          "Enter your account's email address.",
          'Set a new password with the link in the email you receive.',
        ],
      ),
      GuideTopic(
        'Security verification: location, phone and second step',
        intro: 'To stop fake accounts, the app may ask you for these steps.',
        steps: [
          "Location: the app asks for location permission. If you don't allow it, the app won't open and you'll see a screen that leads to your settings. "
              'Your location is used only for account security and is never shown to anyone.',
          "Phone: you enter a number from the country you're in and type the code from the SMS. This is done once; a number can be used on only one account.",
          'Second step: each time you sign in on a new device, an SMS code is sent to your registered number. If you set up an authenticator app or fingerprint, you use that instead.',
        ],
        tip: 'After verifying your phone, accept the "Add fingerprint" or "Add Google Authenticator" suggestion to make later sign-ins faster. SMS stays as a backup.',
      ),
      GuideTopic(
        'Legal documents and date of birth',
        intro: 'You need to accept the Terms of Use, the Privacy Notice, Explicit Consent and the Community Guidelines.',
        steps: [
          "Open each document and scroll to the end. The box can't be ticked until the text has been read.",
          'Tap "I have read and accept" at the end of the document.',
          "Enter your date of birth. It's never shown to anyone and can't be changed later; if you entered it wrong, write to the support team.",
        ],
        notes: ['When a new version of a document is published, the app asks you to accept it again.'],
      ),
      GuideTopic(
        'Creating your profile',
        steps: [
          'Choose a username: 3–30 characters; lowercase letters, numbers, underscores and dots are allowed.',
          'Add your display name and profile photo.',
          'Pick your interests (up to 10). Groups and suggestions are based on them.',
        ],
        notes: ['You can change your username once every 30 days.'],
      ),
      GuideTopic(
        'Finding your way around the app',
        intro: 'The bar at the bottom has four tabs and a "+" button in the middle.',
        notes: [
          'Today: live broadcasts right now, events starting soon and posts from people you follow. Search, Notifications and Messages are at the top right.',
          'Groups: search and discover groups. Groups League and Map are at the top right.',
          "Calendar: events you're going to and your groups' events.",
          'Me: your own profile. Notifications, Saved, Matching, Find teammates, Year in review and Settings are at the top right.',
          'The "+" button: Tonight, Upcoming, and creating a post, story or group.',
          "On wide screens (web, tablet) the same sections are in the menu on the left, with the groups you're in listed below.",
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'profile',
    title: 'Profile and following',
    summary: 'Editing your profile, privacy, following, blocking, badges.',
    topics: [
      GuideTopic(
        'Editing my profile',
        steps: [
          'On the Me tab, tap the Settings button at the top right, then "Edit profile".',
          'Change your profile photo, cover image, display name, bio and interests.',
          'Save.',
        ],
        notes: ['Images can be up to 5 MB (JPEG, PNG or WebP).'],
      ),
      GuideTopic(
        'Private account',
        intro: 'When Settings → "Private account" is on, only followers you approve see your posts and stories.',
        notes: [
          "With a private account, people who want to follow you send a request; you approve or decline it at the top of the Notifications screen. People you decline aren't told.",
          'When you make your account public again, pending requests are approved automatically.',
        ],
      ),
      GuideTopic(
        'Showing my groups on my profile',
        intro: 'Settings → "Show my groups on my profile" is off by default.',
        notes: [
          "While it's off, only members of a group can see that you're in it. An admin of another group can't see which groups you're in.",
          'If you turn it on, your memberships are visible to everyone on your profile.',
          "Groups where you're on the management team (owner, admin, board, moderator) are always public.",
        ],
      ),
      GuideTopic(
        'Following and friends',
        steps: [
          'Tap "Follow" on a profile. If the account is private, a request is sent and following starts once it is accepted.',
          'Tap the same button again to unfollow or withdraw your request.',
        ],
        notes: [
          'If you follow each other, the profile says "Friend".',
          'You can remove someone who follows you from your followers list.',
          "Following doesn't let you message someone; one-to-one messages are between matches and teammates.",
          "You can follow groups too; posts from groups you're in already appear in your feed.",
        ],
      ),
      GuideTopic(
        'Blocking someone',
        steps: [
          'On the person\'s profile, open the "More options" menu at the top right.',
          'Tap "Block".',
        ],
        notes: [
          "Follows and requests in both directions are removed. You won't see each other's profiles, posts or comments; you can't message or mention each other.",
          "The blocked person won't appear in your matching deck or teammate suggestions either.",
          "You'll find the people you've blocked in Settings → \"Blocked accounts\", where you can unblock them. Following doesn't come back automatically after unblocking.",
        ],
      ),
      GuideTopic(
        'Contributions and badges',
        intro: "The contributions on your profile are counted from what you do in real life; likes, followers and post counts don't count.",
        notes: [
          'Attendance: finished events you joined and were not marked "didn\'t come".',
          'Organizing: events you created that at least 2 other people attended.',
          'Memory: posts you shared linked to an event.',
          'Example badges: First step (1 event), Regular (10), Fellow traveler (25), Explorer (3 different groups), Organizer, Memory keeper, Feedback giver, "<category> enthusiast", welcome and handshake badges, and goals you completed.',
          'There are no rankings or "top" lists.',
        ],
      ),
      GuideTopic(
        'Saved posts and story archive',
        notes: [
          'To save a post, tap the save icon on its card. Only you can see what you saved: Me → Saved or Settings → Saved.',
          "Expired stories aren't deleted; they stay in Settings → \"Story archive\".",
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'feed',
    title: 'Today, posts and stories',
    summary: 'Sharing, likes, comments, explore and search.',
    topics: [
      GuideTopic(
        'The Today screen',
        notes: [
          'At the top, "Live now": live broadcasts in your groups. Tap a card to join.',
          'Then "Starting soon": events starting in the next few hours; your own groups\' first, then those in your groups\' provinces.',
          'Below is the feed: your posts and posts from people you follow and groups you follow or belong to, newest first.',
          'Pull the screen down to refresh.',
        ],
      ),
      GuideTopic(
        'Sharing a post',
        steps: [
          'Tap the "+" button at the bottom, then "Post".',
          'Choose up to 10 photos or videos. A video can be up to 60 seconds and 50 MB.',
          'For photos, pick the aspect ratio (Original, 1:1, 4:5, 1.91:1) and adjust the crop.',
          'Write a caption. You can add #hashtags and mention someone with @username.',
          'If you like, turn off comments or hide the like count, then share.',
        ],
        notes: [
          'Location data is removed from your photos before upload.',
          'You can edit a post later; only the caption and options change. If you delete it, its media is deleted too.',
          'To post to a group, share from the group page. Every member can post; muted members cannot.',
        ],
      ),
      GuideTopic(
        'Likes, reactions and comments',
        notes: [
          'You can like a post or leave a reaction with one of 😍 😂 😮 👏 🔥 🙏. You can change or remove your reaction.',
          'Anyone who can see a post can comment, unless the author turned comments off.',
          'You can reply to a comment and like comments. Replies are one level deep.',
          "You delete your own comments and comments on your own posts. On group posts, the group's owner and admins can delete comments too.",
        ],
      ),
      GuideTopic(
        'Sharing a story',
        steps: [
          'Tap "+" → "Story".',
          'Choose a photo or a video of up to 60 seconds and share.',
        ],
        notes: [
          'A story is visible for 24 hours, then moves to your archive.',
          'Only you can see who viewed your story.',
          'You can add stories to highlights to keep them on your profile.',
        ],
      ),
      GuideTopic(
        'Explore and search',
        steps: [
          'Tap the Search button at the top right of the Today screen.',
          'Search for people or #hashtags. Use the Groups tab to search for groups.',
        ],
        notes: [
          "Explore shows the most engaging posts of the last two weeks from public accounts and groups you don't follow.",
          'You can share a link to a post; the person who opens it sees it if they are allowed to.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'groups',
    title: 'Groups',
    summary: 'Finding and joining groups, roles and the group page.',
    topics: [
      GuideTopic(
        'Finding a group',
        notes: [
          'On the Groups tab, search by name or pick a category.',
          'Use the Map button at the top right to see groups and events around you on a map.',
          'Use the Groups League button to see the groups running the best events in your category and province.',
          'Every active group has a public page; there are no hidden groups.',
        ],
      ),
      GuideTopic(
        'Joining a group',
        intro: "The group's join type is shown on the button:",
        notes: [
          'Open: tap "Join" and you become a member right away.',
          "By request: you send a request and the group's admin approves it. You can withdraw your request.",
          'By invitation: an admin invites you by username; you accept or decline on the Notifications screen.',
          'Invite link: open the link you were sent and tap "Join group" to become a member, whatever the join type.',
          "If the group's plan member limit is reached, no new members can join.",
        ],
        tip: 'When you join your first group, you get a one-time 30-day trial of the "All in One" personal plan (matching and teammate features).',
      ),
      GuideTopic(
        'Leaving a group',
        steps: [
          'Tap the membership button on the group page.',
          'Choose "Leave group".',
        ],
        notes: [
          "Your roles are removed and you're taken off the group's upcoming events.",
          "The group owner can't leave the group; ownership must be transferred first.",
        ],
      ),
      GuideTopic(
        "What's on a group page?",
        notes: [
          'Cover, logo, description, rules, links, province and category.',
          'Live card: ongoing and scheduled broadcasts.',
          'Events, "How was it?" reviews and the group\'s average rating.',
          'Polls, goals, the league card and group posts.',
          "Members: the management team is public; only the group's members see the full member list.",
          'Group chat: every group has a single chat that only members can read and write in.',
        ],
      ),
      GuideTopic(
        'Roles in a group',
        intro: 'A member can have more than one role. The number in brackets is the rank.',
        notes: [
          'Group Owner (100): everything, payment and assigning roles.',
          'Admin (80): content, events, polls, approving and inviting members, live broadcasts, bans without a vote, voice call requests.',
          'Disciplinary Board (60): votes on disciplinary cases; reviews reports, emergency mutes, live moderation.',
          'Moderator (50): first review of reports, emergency mutes, live moderation.',
          'Member (10): attending, posting, joining live broadcasts.',
          "Rank rule: nobody can sanction someone of equal or higher rank. The group owner can't be banned.",
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'group-admin',
    title: 'Creating and managing a group',
    summary: 'For owners and admins: group, invitations, roles, plans, goals.',
    topics: [
      GuideTopic(
        'Creating a group',
        steps: [
          'Tap "+" → "Group".',
          "Enter the group's name (3–60 characters) and address. The address is the page link (/g/address) and can't be changed later.",
          'Choose the category and province. The province is needed for the map and the Groups League.',
          'Choose the join type: open, by request or by invitation.',
          'Add a logo, cover, description, rules and up to 5 links.',
        ],
        notes: ['The person who creates the group is its owner. The group also gets its own chat.'],
      ),
      GuideTopic(
        'Accepting and inviting members',
        notes: [
          'In a group that takes requests, you approve or decline pending requests on the group page (owner and admins).',
          'You can send invitations by username. A group can send up to 50 invitations in 24 hours; withdrawn invitations count too.',
          "You can withdraw an invitation until it's accepted.",
        ],
      ),
      GuideTopic(
        'Invite link',
        intro: 'The easiest way to bring your group over from WhatsApp or Instagram.',
        steps: [
          'Open the "Invite link" section on the group page.',
          'Choose how long it lasts (1, 7 or 30 days); optionally set a usage limit (1–1000 people).',
          'Share the link. Whoever opens it, signs in and taps "Join group" becomes a member.',
        ],
        notes: [
          'A group can have up to 20 valid links at a time.',
          "You can revoke a link at any time; revoking can't be undone, you create a new one.",
          "On WhatsApp, a shared link shows a preview with the group's name and image.",
        ],
      ),
      GuideTopic(
        'Assigning roles and transferring ownership',
        notes: [
          'Only the group owner gives and removes roles: Admin, Disciplinary Board, Moderator. Roles can only go to members.',
          'You can transfer ownership to an active member. You stay on as a regular member; the new owner can give you a role.',
          'Only the owner can delete the group. Deleting is permanent.',
          "While you own a group, you can't delete your account; transfer ownership or delete the group first.",
        ],
      ),
      GuideTopic(
        'Group plans',
        intro: "A plan sets the group's maximum number of members, monthly events and monthly live minutes.",
        steps: [
          'Open the "Plan" card on the group page to see the current plan, its limits and usage.',
          'Buy the plan on the web. The mobile app only shows the plan status.',
        ],
        notes: [
          "A group without a subscription uses the free plan's limits.",
          "Plans are prepaid (monthly or yearly); there's no automatic renewal and no card is stored.",
          'When you upgrade, your remaining time carries over to the new plan. If you renew the same plan, the time is added to the end.',
          'Payments from Turkey are taken in TRY via PayTR, and from abroad in USD via iyzico.',
          'If the member limit is reached, existing members stay but no new members can join.',
          'Current prices and limits are shown on the plan screen. The owner buys the plan.',
        ],
      ),
      GuideTopic(
        'Goals and tasks',
        intro: "Brings the group together around a shared aim. The owner and admins create goals; the reward is a badge, there's no money or points.",
        notes: [
          'Personal goal: each member earns a badge when they reach their own number.',
          "Group goal: when the group's total reaches the target, everyone who contributed earns a badge.",
          "Team goal: teams are formed and each team's total is counted.",
          'Task: a member taps "I did it" and adds a short note; if an admin approves, a badge is awarded.',
          'What counts: attendance, organizing or memories. The server calculates progress.',
        ],
      ),
      GuideTopic(
        'Managing the group chat',
        notes: [
          'You can set the group chat so that only admins can write (like an announcement channel).',
          "If an inappropriate message is reported, it goes to the group's moderation screen and an authorized person can remove it.",
        ],
      ),
      GuideTopic(
        'Answering voice call requests',
        intro: 'Members ask the group for permission to make one-to-one voice calls. The group owner and admins see the requests.',
        steps: [
          'Open "Voice call requests" on the group page.',
          'Approve the request, or decline it with a reason.',
          'You can turn off a permission you granted at any time, with a reason.',
        ],
        notes: ['If the person leaves the group, is removed or banned, their permission turns off automatically.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'events',
    title: 'Events',
    summary: 'Joining, the waiting list, welcomes, handshakes, reviews.',
    topics: [
      GuideTopic(
        'Joining an event',
        steps: [
          "Open the event's page (from the group page, the Today screen, the calendar or the map).",
          'Read the date, place, fee information, requirements and the equipment you need.',
          'Tap "Join". If it\'s full, the button says "Join the waiting list".',
        ],
        notes: [
          "Anyone can see events, but only the group's members can join.",
          "If you're on the waiting list, your turn comes when someone drops out and you get a notification.",
          'For events with approval, the button says "Send a request to join"; you join once the organizer approves.',
          'To drop out, tap "Cancel"; your place goes to the first person on the waiting list.',
          'Joining closes once the event starts.',
        ],
      ),
      GuideTopic(
        'Attendance fee',
        intro: "The fee is shown for information only. GWAY doesn't take payments; you pay the organizer the way they say (for example, cash on the day).",
      ),
      GuideTopic(
        'Add to calendar and directions',
        notes: [
          '"Add to calendar" adds the event to your phone\'s calendar app.',
          "If a meeting point is marked, \"Directions\" under the small map on the page opens your device's map app.",
        ],
      ),
      GuideTopic(
        'Two events at the same time',
        intro: "If another of your events is at the same time as one you've joined, the app asks whether you want to drop out of the other and free up your place. It's your choice; nothing is cancelled automatically.",
      ),
      GuideTopic(
        '"Are you coming?" check',
        intro: 'Less than 24 hours before the start, you get a reminder and an "Are you coming?" card appears on the event page.',
        notes: [
          '"Yes, I\'m coming": the organizer sees that you\'re coming.',
          '"I can\'t make it": you drop out; your place goes to the first person on the waiting list.',
          "If you don't answer, you aren't removed from the list.",
        ],
      ),
      GuideTopic(
        "Welcome: if it's your first time",
        intro: "If it's your first time at one of a group's events, a volunteer member of the group can welcome you.",
        steps: [
          'Join the event.',
          'In the welcome section of the page, tap "I\'d like to be welcomed"; optionally add a note describing yourself (e.g. "I\'m in a red jacket").',
          'When a welcomer takes your request, you get their meeting note (e.g. "In front of the café at the entrance, 08:45") as a notification.',
          'After the event you can thank your welcomer.',
        ],
        notes: [
          'To be a welcomer, join the event; you see open requests in the welcome section. You can welcome up to 3 people per event.',
          'Welcome badges: Door opener (1), Host (5), Heart of the community (20).',
        ],
      ),
      GuideTopic(
        'Surprise venue',
        intro: 'At some events the venue is a surprise. The page shows only a hint (e.g. "In Kadıköy, by the sea") and when the venue will be revealed.',
        notes: [
          'At reveal time, the venue is sent to attendees as a notification.',
          "People on the waiting list and those not attending don't see the venue. If you join later and the time has passed, you see it right away.",
        ],
      ),
      GuideTopic(
        'Handshake: save the people you met',
        intro: "Two people at the same event scan each other's QR code to save that they met.",
        steps: [
          'The "Handshake" card shows on the page from 1 hour before the event until 6 hours after it ends.',
          "Show your code or scan the other person's code with the camera. Without a camera, type the 6-character code.",
        ],
        notes: [
          'The code changes every 3 minutes; a photo of it is useless later.',
          'Only you see who you met: Me → Year in review button → People I met. Your profile shows only the number.',
          "A handshake doesn't let you message someone.",
        ],
      ),
      GuideTopic(
        'After the event',
        notes: [
          "Once it's over, you get a request to review it; give 1–5 stars. The group's rating is the average of these reviews.",
          'You can add your memory by sharing a post linked to the event; memories count toward badges and goals.',
          'If you attended, an "I was there too" card appears on the page; you can share it as an image to an Instagram story or WhatsApp. The card has no other attendee\'s name or face.',
          "You can see the group's past events on the group page.",
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'event-admin',
    title: 'Organizing events and polls',
    summary: 'For owners and admins: creating, repeating, approval, cancelling, polls.',
    topics: [
      GuideTopic(
        'Creating an event',
        steps: [
          'Tap "Create event" on the group page.',
          'Enter the cover, title, description, start time and an optional end time. The start must be at least 15 minutes and at most 1 year ahead.',
          'Enter the place; optionally pin the meeting point on the map or add an online link.',
          'Add the capacity (leave it empty for unlimited), fee information, requirements and the equipment list.',
          'If needed, turn on "Require approval to join" and save.',
        ],
        notes: [
          "The form shows how many events you have left this month. Cancelled events count toward your plan's monthly limit.",
          'The form also shows how many events other groups in the same category have in your province that day; you can change the date if you like.',
        ],
      ),
      GuideTopic(
        'Repeating events',
        intro: 'When creating, choose "Every week" or "Every two weeks" under "Repeat" to start a series (with an optional end date, up to 1 year).',
        notes: [
          'A series always keeps the next 4 weeks open. Each date has its own attendees and waiting list.',
          'If you edit the latest date, dates opened afterwards follow it.',
          'Use "Stop repeating" in the event menu to stop the series; dates already open stay, and you can cancel them one by one.',
          "If the monthly limit is reached, the date doesn't open and you get a notification; it opens once the limit frees up.",
        ],
      ),
      GuideTopic(
        'Setting up a surprise venue',
        steps: [
          'Turn on "Surprise venue" in the form.',
          'Write a hint in the "Place" field; enter the real venue and meeting point separately.',
          'Choose when to reveal it: 1, 3, 6, 12 or 24 hours before the start.',
        ],
        notes: ['If you turn the surprise off, the hidden venue is deleted and "Place" becomes the normal place.'],
      ),
      GuideTopic(
        'Managing attendees',
        notes: [
          'With approval required, you approve or decline pending requests.',
          'The attendee list shows who confirmed "Are you coming?".',
          'After the event you mark no-shows as "didn\'t come"; those marked don\'t count as having attended.',
          'Editing: the title, description, time, place, capacity, fee and cover can change. If the time or place changes, attendees are notified. Capacity can\'t go below the number attending.',
          "Cancelling: you cancel with a reason; attendees and people waiting are notified. Past events can't be edited.",
        ],
      ),
      GuideTopic(
        'Creating a poll and voting',
        steps: [
          'Tap "Create poll" on the group page (owner and admins).',
          'Write the question and 2–10 options.',
          'Optionally allow multiple choices, make the poll anonymous, set an end time or link it to an event.',
        ],
        notes: [
          "Only the group's members see polls and results.",
          'In an anonymous poll nobody can see who voted for what, not even the person who created it.',
          'Once a poll closes, no more votes can be cast and the results stay. An authorized person can close a poll early or delete it.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'calendar',
    title: 'Calendar, Tonight and discovery',
    summary: "Calendar, I'm free tonight, small tables, the map, the league, Year in review.",
    topics: [
      GuideTopic(
        'My calendar',
        notes: [
          "The Calendar tab shows events you've joined, are waiting for approval on or are on the waiting list for.",
          'Turn on "My groups\' events" to also see all events of the groups you\'re in.',
          'Switch between day, week and month views.',
          'Events that overlap in time are marked.',
          "You can also open a group's calendar from its page.",
        ],
      ),
      GuideTopic(
        "I'm free tonight",
        steps: [
          'Tap "+" → "Tonight".',
          'Turn on "I\'m free tonight"; optionally add a short note (e.g. "coffee, short walk").',
        ],
        notes: [
          'Only people who share at least one group with you see your status.',
          'Your status turns off automatically at 04:00; you can also turn it off yourself at any time.',
        ],
      ),
      GuideTopic(
        'Small table',
        intro: 'Sets up a small meetup with people who are free tonight.',
        steps: [
          'Tap "Set up a small table" on the "Tonight" page.',
          'The app picks and invites 3–5 people who share groups with you and are free tonight.',
          'You chat with those who accept in the table\'s chat.',
        ],
        notes: [
          'There must be at least 2 people who can be invited; otherwise the card says how many more are needed.',
          'You can join only one table per night.',
          'The table closes at 12:00 the next day; the chat can still be read but not written in.',
        ],
      ),
      GuideTopic(
        'Discovering with the map',
        steps: [
          'Tap the Map button at the top right of the Groups tab.',
          'Move the map; filter by category, time (today, 7 days) and distance from the center of the map (5–50 km).',
          'Choose the map or list view.',
        ],
        notes: [
          "The map shows only upcoming events and active groups. Your location isn't used on the map and isn't shown to anyone.",
          'If the map is temporarily off, it says "The map is not available right now." on top.',
        ],
      ),
      GuideTopic(
        'Groups League',
        intro: 'Groups in the same category and province earn points every month by running good events.',
        notes: [
          'Points: every attendee, every event with at least 3 attendees, every welcome and every 4–5 star review.',
          'In a tie, the group with fewer members comes first.',
          'When the month closes, members of the top three groups are notified; rankings show on the league card on the group page.',
        ],
      ),
      GuideTopic(
        'Year in review and my exploration map',
        steps: [
          'Tap the Year in review button at the top right of the Me tab.',
          'Choose "Year in review", "My exploration map" or "People I met".',
        ],
        notes: [
          'Year in review: the number of events you attended, total hours, the groups, provinces and categories you went to. You can share it as a story card.',
          'My exploration map: the provinces of the events you attended fill in on the map of Turkey ("I\'ve explored 7 / 81 provinces").',
          'Only you see these pages; nobody else can unless you share them.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'live',
    title: 'Live audio',
    summary: 'Joining, speaking, reactions, starting and running a broadcast.',
    topics: [
      GuideTopic(
        'Joining a broadcast',
        steps: [
          'Tap the "Live now" card on the Today screen, the live card on the group page or the broadcast notification.',
          'Once connected, you see who is on stage and who is listening.',
        ],
        notes: ["Only the group's members can join. Someone removed from a broadcast can't rejoin it."],
      ),
      GuideTopic(
        'Using the app during a broadcast',
        intro: "Pressing back or the down arrow at the top left doesn't take you out of the broadcast; the broadcast screen shrinks and the audio keeps playing.",
        notes: [
          'A "You\'re live" strip appears at the top of every page. Tap it to go back to the broadcast.',
          "If you're on stage, you can also mute and unmute your mic from the strip.",
          'To leave, tap "Leave" on the broadcast screen. If you join another broadcast, you leave the previous one.',
        ],
      ),
      GuideTopic(
        'Speaking: raising your hand and the stage',
        steps: [
          "If you're listening, raise your hand with the ✋ button.",
          'When a host brings you on stage, a mic button appears; tap it to unmute and speak.',
          'To leave the stage yourself, tap "Leave stage".',
        ],
        notes: [
          "If a host muted your mic, you can't unmute it; only a host can turn it back on.",
          "The speaker's photo lights up around the edge.",
        ],
      ),
      GuideTopic(
        'Reactions and comments',
        notes: [
          "Send ❤️ 👏 😂 🔥 😮 🙌 with the reactions button; they float across the screen and aren't stored.",
          "Write comments with the comments button. Comments stay with the broadcast's record.",
          "Press and hold your own comment to delete it; you can report someone else's comment.",
        ],
      ),
      GuideTopic(
        'Starting a broadcast',
        intro: 'The group owner and admins start broadcasts.',
        steps: [
          'Tap "Start broadcast" on the live card on the group page.',
          'Write a title. Start right away or schedule it for later.',
        ],
        notes: [
          'A group can have one live broadcast and up to five scheduled ones at a time.',
          'A scheduled broadcast shows as "Upcoming" on the group page; members tap "Remind me". The host can start a scheduled broadcast at most 15 minutes early.',
          "Live minutes depend on the group's plan; the start screen shows the minutes left. When they run out, the broadcast ends automatically.",
          "If the host leaves and doesn't return within 2 minutes, the broadcast ends automatically.",
        ],
      ),
      GuideTopic(
        'Running a broadcast',
        intro: "The person who started the broadcast and the group's moderation team are its hosts.",
        notes: [
          'Tap someone to bring them on stage, move them off stage, or mute or unmute their mic.',
          '"Remove from broadcast": the person can\'t rejoin this broadcast.',
          'You see raised hands on the "raised a hand" card at the top.',
          '"End the broadcast for everyone" is in the menu at the top right.',
          'Up to 10 people can be on stage, including the host. The rank rule applies here too.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'messages',
    title: 'Messages and voice calls',
    summary: 'Who you can message, group chats, message privacy, voice calls.',
    topics: [
      GuideTopic(
        'Who can I message?',
        notes: [
          "One-to-one messages are open only with your matches and teammates. Following doesn't let you message someone.",
          'Writing to a match needs the Match Chat plan, and writing to a teammate needs the Teammate plan. Reading messages you receive is free.',
          "Group chats are free; all the group's members can write.",
          'The Messages screen is behind the Messages button at the top right of Today. The unread count shows on the button.',
        ],
      ),
      GuideTopic(
        'Writing and deleting messages',
        notes: [
          'You can send text (up to 2,000 characters) and a photo.',
          'While a message is sending, it says "Sending…". If it fails, the text goes back into the box with the reason.',
          'In a one-to-one chat, it says "Seen" once the other person reads it.',
          'You can delete your own message for everyone; it shows "This message was deleted" and its content is removed completely.',
        ],
      ),
      GuideTopic(
        'Message privacy',
        intro: "The GWAY platform team can't read your private messages, listen to your voice calls or see who called whom.",
        notes: [
          "You can report a message. Reports of one-to-one messages go to the platform team; reports of group chat messages go to the group's moderation.",
          "A group's disciplinary board can't see your one-to-one messages.",
        ],
      ),
      GuideTopic(
        'Getting voice call permission',
        intro: "One-to-one voice calls aren't open to everyone; the owner or an admin of a group you belong to grants permission.",
        steps: [
          'Open Settings → "Voice calls".',
          'Choose a group you belong to, optionally write a short note and send the request.',
          'You see your status on the same screen: under review, on or off (with the reason). The decision also comes as a notification.',
        ],
        notes: ['If you leave the group that granted it, your permission turns off.'],
      ),
      GuideTopic(
        'Making a voice call',
        steps: [
          'Open your chat with a match or a teammate.',
          'Tap the "Voice call" button at the top right.',
        ],
        notes: [
          "Both of you need call permission and the same plan access as for the chat. If you can't call, the reason is shown in place of the button.",
          'A call not answered within 30 seconds becomes a missed call. A call lasts up to 60 minutes.',
          'Calls are never recorded and are end-to-end encrypted. If the 12-digit safety code on screen is the same for both of you, nobody is listening in.',
          "You can be on only one call at a time; someone who's busy can't be called.",
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'matching',
    title: 'Matching and teammates',
    summary: 'Friends and dating matches, personal plans, finding teammates.',
    topics: [
      GuideTopic(
        'How does matching work?',
        intro: 'Matching helps you find friends or a partner among people who share groups with you. It uses a separate matching profile; nobody sees you there unless you turn it on.',
        steps: [
          'Tap the Matching button at the top right of the Me tab (in the left menu on wide screens).',
          'Create your matching profile: Friends, Dating or both; 2–6 photos, date of birth, gender, province, "about me".',
          'In Dating, choose the genders you\'re looking for and an age range.',
          'Give your explicit consent.',
        ],
        notes: [
          'Your deck shows only people who share at least one group with you and turned on the same mode.',
          'In Dating, both of your preferences must match each other.',
          'Only your province is used as a location.',
        ],
      ),
      GuideTopic(
        'Swiping and matching',
        notes: [
          'Swipe right: like. Left: pass. Up: Super Like. The buttons at the bottom do the same.',
          'Tap the edges of a card to switch photos; the "i" button opens the full profile.',
          "If you both like each other in the same mode, it's a match and you're notified.",
          'Your free daily likes and Super Likes are shown on the matching screen.',
          'Someone you passed can be suggested again after 90 days.',
        ],
      ),
      GuideTopic(
        'Personal plans',
        intro: 'Each feature is sold as its own plan; you get only what you want.',
        notes: [
          'My matches: see who you matched with. Without it you know you matched, but the person stays hidden.',
          'Match Chat: write to your matches.',
          'Who Likes You: the list of people who liked you.',
          'Unlimited Likes: unlimited likes, undo and filters.',
          'Super Like and Boost: more Super Likes, and appearing at the top of decks once a day.',
          'Teammate: the teammates section and writing to teammates.',
          'All in One: everything.',
          "Plans are prepaid, don't renew automatically and are bought on the web. Prices are shown in Matching → Plans.",
        ],
      ),
      GuideTopic(
        'Ending, pausing and deleting matching',
        notes: [
          "If you end a match, your chat closes, mutual follows are removed and you won't appear in each other's decks.",
          'If you matched in both modes, you can choose "Stay friends only" or "Keep dating only".',
          'If you pause your profile, your deck and likes stop; existing matches stay.',
          'You can delete all your matching data (profile, photos, likes, matches) with one tap.',
          'You can report matching profiles and photos.',
        ],
      ),
      GuideTopic(
        'Finding teammates',
        intro: 'Find people to train, hike or perform with.',
        steps: [
          'In Settings → "Teammate preferences", turn on "Looking for a team".',
          'Choose your activities, level, goals, frequency, available times and, optionally, your province.',
          'On the Me tab, use the "Find teammates" button to see suggestions. Each one says why (shared activity, shared group, same province…).',
          'Send a request (with a message of up to 200 characters). Once the other person accepts, you\'re teammates.',
        ],
        notes: [
          "Your province is used only for matching and isn't shown on your profile.",
          'You can send up to 20 requests a day, and one request a day to the same person.',
          'The teammates section needs the Teammate plan.',
          'Either side can end the teammate connection at any time.',
        ],
      ),
    ],
  ),
  GuideChapter(
    id: 'notifications',
    title: 'Notifications',
    summary: 'Notification types, preferences and phone notifications.',
    topics: [
      GuideTopic(
        'The Notifications screen',
        notes: [
          'Open it with the bell button at the top right of Today; the unread count shows on the button.',
          'Notifications are grouped into Today / This week / Earlier; pending follow requests are at the top.',
          'Tap a notification to open the related page.',
        ],
      ),
      GuideTopic(
        'Notification preferences',
        steps: ['Open Settings → "Notification preferences".', "Turn off the ones you don't want."],
        notes: [
          'You can turn off: event reminders, event changes and cancellations, review requests, live notifications, personal messages, group messages and matching notifications.',
          "Notifications that concern you directly, such as join approvals, your turn coming up or sanctions, can't be turned off.",
        ],
      ),
      GuideTopic(
        "Phone notifications aren't arriving",
        steps: [
          "The app asks for notification permission the first time it opens; if you didn't allow it, turn it on in your phone's Settings → Apps → GWAY → Notifications.",
          'On Android, check that the "Messages", "Voice calls" and "Notifications" channels are on.',
          'Check the notification preferences in the app.',
        ],
        notes: ["If your phone is on silent, notifications won't make a sound."],
      ),
    ],
  ),
  GuideChapter(
    id: 'safety',
    title: 'Safety, reports and sanctions',
    summary: 'Reporting, group sanctions, appeals, two-step verification.',
    topics: [
      GuideTopic(
        'Reporting',
        steps: [
          'Open the menu of the post, comment, event, live comment, message or profile.',
          'Tap "Report", choose a reason and optionally write a short description.',
        ],
        notes: [
          "The person you report doesn't see the report or you. The group's admins don't see who reported either.",
          "Reports about a group go to the group's moderation; others go to the platform team.",
          "You can't report yourself or your own content; you can report the same content once while the report is open.",
        ],
      ),
      GuideTopic(
        'Group sanctions',
        notes: [
          "Warning: it's recorded and you get a notification.",
          "Mute (1–90 days): you can't post or comment in the group or write in the group chat; in live broadcasts you can only listen.",
          'Removal: you are removed from the group; you can join again later.',
          "Ban (temporary or permanent): while it lasts, you can't join the group, send requests or receive invitations.",
          'Your sanctions are shown in Settings → "My group sanctions".',
        ],
      ),
      GuideTopic(
        'Appealing a sanction',
        steps: [
          'Open Settings → "My group sanctions".',
          'Tap "Appeal" next to the sanction and write your reasons (10–1000 characters).',
        ],
        notes: [
          "You can appeal each sanction once within 7 days. Emergency mutes can't be appealed.",
          'The group owner decides on the appeal; if the owner is a party to the case, the platform team decides.',
          'The sanction continues while the decision is pending. You get the decision as a notification.',
        ],
      ),
      GuideTopic(
        'Account suspension and ban',
        notes: [
          'The platform team can suspend or close an account that breaks the rules. In that case, the app shows you the reason and the end date.',
          'While suspended, your profile is visible but your content is hidden; a permanently closed account appears nowhere.',
          'If illegal activity (such as violence, threats or fraud) is marked by a group decision, the account is suspended pending the platform\'s review.',
          'If you think there has been a mistake, write to the support team.',
        ],
      ),
      GuideTopic(
        'Two-step verification',
        steps: [
          'Open Settings → "Two-step verification".',
          'Add an authenticator app (e.g. Google Authenticator), or on the web set up sign-in with fingerprint and face recognition.',
        ],
        notes: ['The method you set up comes first at later sign-ins; SMS always stays as a backup.'],
      ),
    ],
  ),
  GuideChapter(
    id: 'moderation',
    title: 'Group moderation',
    summary: 'For moderators: reviewing reports, disciplinary cases, voting, bans.',
    topics: [
      GuideTopic(
        'The moderation screen',
        intro: 'The moderation card on the group page shows the number of pending tasks. The owner, admins, board members and moderators see it.',
        notes: [
          'Reports: reports about the same content are grouped in one row. Dismiss, Remove content or Open case.',
          'Cases: cases being voted on, the time left and the vote counts; cast your vote.',
          'Sanctions and appeals: the owner decides on appeals here.',
        ],
      ),
      GuideTopic(
        'Disciplinary cases and voting',
        steps: [
          'From a report, or from the member menu on the members page, choose "Open a disciplinary case".',
          'Choose the proposed sanction (warning, mute, removal, ban) and its duration, and write the reason.',
          'In an emergency, tick "Mute now (24 hours)"; the person is muted until there is a decision.',
        ],
        notes: [
          'Disciplinary Board members vote within 72 hours. In a group without a board, the owner decides alone.',
          'The decision threshold is a simple majority by default; the owner can choose two-thirds or unanimous in the moderation screen settings.',
          'Once the threshold is passed, the case is approved right away and the sanction is applied. If nobody votes, the case is rejected.',
          'Only one open case can exist about a person at a time. The rank rule applies.',
        ],
      ),
      GuideTopic(
        'Ban without a vote',
        intro: 'The group owner and admins can ban someone without waiting for the board.',
        steps: [
          'In "Open a disciplinary case", choose ban as the sanction.',
          'Tick "Apply now, without a vote".',
          'Enter the duration (1–365 days or permanent) and the reason.',
        ],
        notes: [
          "An admin can't ban another admin or the owner.",
          "If it's a crime, mark it as \"illegal activity\" and choose the category; the person's account is suspended pending the platform's review.",
          'The person can appeal within 7 days.',
        ],
      ),
      GuideTopic(
        'Emergency action in a live broadcast',
        intro: 'In a situation like harassment during a broadcast, a host mutes the person\'s mic right away or removes them from the broadcast. A disciplinary case can then be opened if needed.',
      ),
    ],
  ),
  GuideChapter(
    id: 'account',
    title: 'Account, privacy and support',
    summary: 'Legal documents, your data, deleting your account, signing out, support.',
    topics: [
      GuideTopic(
        'How is my data protected?',
        notes: [
          "Your location is used only for account security; it isn't shown on the map or your profile.",
          'Your date of birth is never shown to anyone.',
          "The platform team can't read your private messages.",
          'The documents you accepted are in Settings → "Legal documents".',
        ],
      ),
      GuideTopic(
        'Deleting my account',
        steps: [
          'Open Settings → "Delete account".',
          'Confirm the deletion.',
        ],
        notes: [
          'Your profile is hidden from others right away. Within 30 days you can sign in and choose "undo deletion".',
          'After 30 days, your account, posts, messages and files are permanently deleted.',
          'If you own a group, you must transfer ownership or delete the group first.',
        ],
      ),
      GuideTopic(
        'Signing out',
        intro: 'Tap "Sign out" at the bottom of Settings. The phone you sign out of no longer gets notifications.',
      ),
      GuideTopic(
        'Writing to the support team',
        steps: [
          'Open Settings → "Support and feedback".',
          'Tap "New message" and choose the type: Problem (something doesn\'t work), Request (something to be done for your account, group or payment), Suggestion (a new feature or idea).',
          'Write the subject and description; you can add up to 3 images.',
        ],
        notes: [
          'When a reply arrives, the row in Settings says "new reply". Message statuses: New, In progress, Resolved, Closed.',
          "If you're a group admin, you can also open a message for that group from the group page.",
        ],
      ),
    ],
  ),
];
