import '../../features/home/domain/child_status.dart';
import '../../features/home/domain/timeline_event.dart';
import '../../features/home/domain/ai_summary.dart';
import '../../features/home/domain/daily_story.dart';
import '../../shared/models/child_model.dart';

class MockData {
  static final Child child1 = Child(
    id: 'c1',
    firstName: 'Emma',
    lastName: 'García',
    classroomId: 'class1',
    classroomName: 'Butterflies',
    avatarUrl:
        'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=150&h=150&fit=crop',
    dateOfBirth: DateTime(2023, 5, 12),
    allergies: ['Peanuts'],
    authorizedPickups: [
      AuthorizedPickup(
        id: 'p1',
        name: 'Carlos García',
        relation: 'Father',
        photoUrl: 'https://i.pravatar.cc/150?u=carlos',
        phone: '+1234567890',
      ),
    ],
  );

  static final Child child2 = Child(
    id: 'c2',
    firstName: 'Liam',
    lastName: 'García',
    classroomId: 'class1',
    classroomName: 'Butterflies',
    avatarUrl:
        'https://images.pexels.com/photos/3771646/pexels-photo-3771646.jpeg',
    dateOfBirth: DateTime(2023, 8, 20),
    allergies: [],
    authorizedPickups: [
      AuthorizedPickup(
        id: 'p1',
        name: 'Carlos García',
        relation: 'Father',
        photoUrl: 'https://i.pravatar.cc/150?u=carlos',
        phone: '+1234567890',
      ),
    ],
  );

  static final dailyStory = DailyStory(
    date: DateTime.now(),
    child: child1,
    status: ChildStatus(
      status: ChildPresenceStatus.checkedIn,
      lastStatusChange: DateTime.now().subtract(const Duration(hours: 6)),
      checkedInBy: 'Mom',
    ),
    aiSummary: AiSummary(
      emoji: '🌟',
      headline: 'Great day!',
      bullets: [
        'Ate all breakfast',
        'Napped 1.5 hours',
        'Loved painting in art class',
      ],
      generatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    events: [
      TimelineEvent(
        id: 'e1',
        type: TimelineEventType.photo,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Photos',
        description: 'Art class was so fun!',
        caregiverName: 'Ms. Patricia',
        photoUrls: [
          'https://picsum.photos/seed/art1/400/300',
          'https://picsum.photos/seed/art2/400/300',
        ],
      ),
      TimelineEvent(
        id: 'e2',
        type: TimelineEventType.nap,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        title: 'Nap',
        napDetails: NapDetails(
          startTime: DateTime.now().subtract(
            const Duration(hours: 4, minutes: 30),
          ),
          endTime: DateTime.now().subtract(const Duration(hours: 3)),
          quality: NapQuality.great,
        ),
      ),
      TimelineEvent(
        id: 'e3',
        type: TimelineEventType.meal,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        title: 'Lunch',
        mealDetails: const MealDetails(
          mealType: MealType.lunch,
          amount: MealConsumption.most,
          notes: 'Grilled chicken, rice, veggies',
        ),
      ),
      TimelineEvent(
        id: 'e4',
        type: TimelineEventType.note,
        timestamp: DateTime.now().subtract(
          const Duration(hours: 5, minutes: 45),
        ),
        title: 'Note',
        description: 'Emma made a new friend today!',
        caregiverName: 'Ms. Patricia',
      ),
      TimelineEvent(
        id: 'e5',
        type: TimelineEventType.checkIn,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        title: 'Check-in',
        description: 'Arrived with Mom',
      ),
    ],
  );

  static final dailyStory2 = DailyStory(
    date: DateTime.now(),
    child: child2,
    status: ChildStatus(
      status: ChildPresenceStatus.checkedIn,
      lastStatusChange: DateTime.now().subtract(const Duration(hours: 5)),
      checkedInBy: 'Dad',
    ),
    aiSummary: AiSummary(
      emoji: '🧗‍♂️',
      headline: 'Very active day!',
      bullets: [
        'Played on the playground',
        'Slept 1 hour',
        'Enjoyed reading time',
      ],
      generatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    events: [
      TimelineEvent(
        id: 'e1_2',
        type: TimelineEventType.photo,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        title: 'Photos',
        description: 'Liam loved the playground!',
        caregiverName: 'Ms. Patricia',
        photoUrls: [
          'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=400&h=300&fit=crop',
        ],
      ),
      TimelineEvent(
        id: 'e2_2',
        type: TimelineEventType.nap,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Nap',
        napDetails: NapDetails(
          startTime: DateTime.now().subtract(const Duration(hours: 3)),
          endTime: DateTime.now().subtract(const Duration(hours: 2)),
          quality: NapQuality.good,
        ),
      ),
      TimelineEvent(
        id: 'e3_2',
        type: TimelineEventType.meal,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        title: 'Lunch',
        mealDetails: const MealDetails(
          mealType: MealType.lunch,
          amount: MealConsumption.all,
          notes: 'He really liked the pasta!',
        ),
      ),
      TimelineEvent(
        id: 'e5_2',
        type: TimelineEventType.checkIn,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        title: 'Check-in',
        description: 'Arrived with Dad',
      ),
    ],
  );
}
