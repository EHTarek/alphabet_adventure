# Product Requirements Specification

## Alphabet Adventure 3D

**Document status:** Product baseline for MVP implementation
**Version:** 1.0
**Last updated:** 2026-09-08
**Product type:** Offline-first educational exploration game
**Primary platforms:** Android and iOS
**Secondary platform:** Web, subject to 3D rendering and audio validation
**Target learner:** Children ages 4-8
**Primary language:** English
**Framework:** Flutter and Dart
**3D strategy:** A Flutter-compatible scene renderer, validated during Phase 1

---

## 1. Executive Summary

Alphabet Adventure 3D teaches early literacy through short, playful exploration sessions. A child meets a letter, hears its name and sound, explores a themed world, interacts with vocabulary objects, completes small challenges, and receives immediate positive reinforcement.

The product must feel like an adventure game with learning embedded in the interaction. It must never feel like a test the child can fail. Audio, animation, and touch are the primary communication channels; text supports those channels but does not replace them.

The MVP delivers:

- All 26 English letters in uppercase and lowercase.
- At least three vocabulary words for every letter.
- Four reusable challenge mechanics plus review.
- Six reusable visual world themes.
- One friendly mascot, Pip the Parrot.
- Local child profiles, progress, settings, rewards, and lesson history.
- A parent area with a privacy-preserving progress summary.

The first production-quality vertical slice is A, B, and C. No full-alphabet content production should be required before the vertical slice validates the interaction model, audio pipeline, rendering approach, performance, and child usability.

---

## 2. Product Vision and Principles

### 2.1 Vision

Create a warm, low-pressure learning world where children build letter recognition, phonics awareness, vocabulary, and early spelling skills by seeing, hearing, and touching meaningful objects.

### 2.2 Product principles

1. **See it, hear it, interact with it.** Every learning target should be represented visually, spoken clearly, and connected to an action.
2. **One primary task at a time.** The child should always understand what to do next without reading a menu.
3. **Encouragement over correction.** Incorrect answers invite another attempt and never remove earned progress.
4. **Short sessions, durable learning.** Lessons should fit a 3-8 minute session and revisit weak content over time.
5. **Content drives behavior.** Letters, words, prompts, audio, assets, and challenge sequences belong in data definitions rather than screen-specific code.
6. **Parents see useful progress without exposing child data.** Reporting should be concise, local-first, and designed for a trusted adult.
7. **Performance is part of the learning experience.** A delayed tap, missing audio clip, or unstable scene breaks the lesson and must be treated as a product defect.

### 2.3 Non-goals for MVP

The MVP does not include reading comprehension, sentence construction, handwriting grading, speech recognition, multiplayer, public profiles, chat, targeted advertising, in-app purchases, cloud synchronization, teacher dashboards, or generative AI tutoring.

---

## 3. Users and Jobs To Be Done

### 3.1 Child learner

**Profile:** A child ages 4-8 who may not read independently and may use the app for a few minutes at a time.

**Needs:**

- Understand what to do through voice, imagery, and motion.
- Touch large, forgiving targets.
- Hear a letter, sound, and word repeatedly without friction.
- Receive positive feedback after every meaningful attempt.
- Resume without losing progress.

**Job:** "Help me discover letters and words by playing, and show me what I learned."

### 3.2 Parent, guardian, or teacher

**Profile:** An adult supporting a child's early literacy practice.

**Needs:**

- See which letters and words are developing or mastered.
- Understand accuracy, practice time, and recent activity.
- Control audio, subtitles, animation, and data settings.
- Access adult-only settings behind a parental gate.

**Job:** "Help me understand whether practice is useful and adjust the experience when needed."

### 3.3 Product and content team

**Needs:**

- Add or revise content without changing gameplay code.
- Validate pronunciation and age suitability.
- Reuse world themes and interaction patterns.
- Measure learning friction without collecting unnecessary personal data.

---

## 4. MVP Scope and Success Definition

### 4.1 In scope

| Area | MVP commitment |
|---|---|
| Alphabet | A-Z, uppercase and lowercase recognition |
| Phonics | One age-appropriate primary sound per letter, with approved audio |
| Vocabulary | Minimum three words per letter; 78 minimum total |
| Lesson modes | Letter Hunt, Object Hunt, Sound Match, Word Builder, Review |
| Worlds | Six reusable themes with data-driven object placement |
| Mascot | Pip the Parrot: instruction, encouragement, transitions |
| Progress | Per-profile letter and word mastery, stars, history, unlock state |
| Storage | Offline local persistence; resume after app restart |
| Audio | Letter names, phonics, words, prompts, mascot, effects, music |
| Parent area | Progress summary and settings, protected by a simple adult gate |
| Platforms | Android and iOS first; Web only after renderer validation |

### 4.2 MVP success criteria

A child can open the app, select or create a profile, complete a letter lesson, hear all required learning audio, interact with objects, earn stars, exit, reopen the app, and see preserved progress without network access.

### 4.3 Product success metrics

| Metric | Initial target | Measurement |
|---|---:|---|
| First-session lesson completion | >= 75% | Local session events and usability testing |
| Average lesson duration | 3-8 minutes | Session timer, excluding idle time where possible |
| Audio replay discoverability | >= 80% of test parents/children can replay | Moderated usability test |
| Correct response rate | Improving across repeat attempts | Letter and word mastery records |
| Progress persistence | 100% in acceptance testing | Restart and interruption test matrix |
| Crash-free sessions | >= 99.5% release target | Platform diagnostics, if enabled |
| Supported-device frame rate | >= 30 FPS, target 60 FPS | Profiled vertical slice |

Engagement alone is not a success metric. Repeated use without improvement in recognition or sound association requires product investigation.

---

## 5. Experience Architecture

### 5.1 Primary loop

```text
Open app
  -> Select child profile
  -> Choose an available lesson
  -> Meet the letter
  -> Hear the challenge
  -> Explore and tap an object or letter
  -> Receive immediate feedback
  -> Complete mixed practice
  -> Earn stars and update mastery
  -> Return to the world map or resume later
```

### 5.2 Standard lesson sequence

The current implementation models this sequence as `introduction`, `objectHunt`, `miniGame`, `review`, and `celebration`.

| Phase | Learner experience | Exit condition |
|---|---|---|
| Introduction | Large letter, name, sound, and first word are presented | Child taps Continue or the guided prompt completes |
| Object Hunt | Child finds one or more objects beginning with the target letter | Required object interactions complete |
| Mini-game | Sound Match, Word Match, or Word Builder reinforces the target | Required challenge is solved or retried |
| Review | A short mixed recall question revisits the letter and word | Review attempt is submitted |
| Celebration | Stars, mascot response, and learned-content summary appear | Child chooses Continue or exits |

The child may pause or leave at any time. Completed challenge results are saved at the next safe checkpoint; an unfinished challenge may be replayed.

### 5.3 Feedback rules

**Correct answer:** Animate the selected item, play success audio, speak the relevant letter or word, show a clear visual confirmation, and award the configured reward.

**Incorrect answer:** Keep the child in the current challenge, use a gentle phrase such as "Let's try again," provide optional visual or audio help, and never subtract stars, lock progress, or show a failure screen.

**Repeated difficulty:** Increase support before increasing pressure. A hint may spotlight the relevant object, replay the prompt, or narrow the available choices. Hints do not invalidate progress.

---

## 6. Screen and Navigation Requirements

### 6.1 Splash and loading

- Show the product mark and Pip while bootstrapping local services.
- Provide visible progress for asset or content initialization when it takes longer than a moment.
- Never block indefinitely on optional network or analytics work.
- Route to the active profile, profile selection, or world map according to local state.

### 6.2 Child profile screen

- Create or select a child profile using a nickname and avatar.
- Use large avatar tiles and audio or icon cues for selection.
- Do not require an email address, real name, date of birth, or other unnecessary personal information.
- Keep profile management and deletion in the parent area.

### 6.3 World map

- Present available letters as a clear path through reusable worlds.
- Show unlocked, in-progress, completed, and mastered states without relying on color alone.
- Allow the child to resume the recommended next lesson with one obvious primary action.
- Let the child replay completed lessons.
- Lock future lessons gently and explain availability through audio or mascot guidance.

### 6.4 Game screen

- Keep the 3D or scene viewport visually dominant.
- Display one short spoken or visual challenge at a time.
- Provide persistent audio replay and pause controls with recognizable icons and accessible labels.
- Display stars and progress without turning the screen into a dashboard.
- Use large touch targets and forgiving hit areas around learning objects.
- Keep the camera guided or limited; free camera movement is out of scope for MVP.

### 6.5 Lesson complete

- Show stars earned, letter(s) practiced, and words encountered.
- Celebrate without timed pressure or forced navigation.
- Provide Continue, Replay, and Return to Map actions appropriate to the child flow.
- Save completion and mastery before navigating away.

### 6.6 Parent area and settings

- Require a simple adult gate before entering adult-only content.
- Show per-letter status, recent practice, accuracy trend, and time practiced.
- Provide settings for narration, music, effects, subtitles, reduced motion, and reset/delete profile.
- Explain privacy and data behavior in parent-readable language.
- Avoid exposing child-facing ads, external links, purchases, or social features.

### 6.7 Navigation contract

The current application routes are `/`, `/profile`, `/world_map`, `/game`, `/lesson_complete`, `/parent`, and `/settings`. Any new route must define its entry state, back behavior, persistence boundary, and child-versus-parent access requirement.

---

## 7. Learning Design and Game Modes

### 7.1 Letter Hunt

The child hears "Find the letter B" and selects the matching uppercase or lowercase letter in the scene. Distractors should be visually distinct at first and become more challenging only after demonstrated progress.

### 7.2 Object Hunt

The child hears "Find something that starts with B" and selects a valid object such as a Bear, Ball, or Banana. The selected object responds with animation and spoken reinforcement.

### 7.3 Sound Match

The app plays the target phoneme, such as /b/, and presents a small set of letter choices. The prompt must not depend on written phonetic notation for the child.

### 7.4 Word Match

The child matches a spoken or shown vocabulary word to its object or initial letter. The word should be spoken before any text is expected.

### 7.5 Word Builder

The child builds a short word from letter tiles, either by tapping tiles in order or by dragging them. Tapping is mandatory for accessibility; drag-and-drop is an enhancement. MVP words should generally be three to five letters and have clear pronunciation.

### 7.6 Review Challenge

Review uses previously introduced letters and words, weighted toward content with lower accuracy or longer time since practice. A review must remain short, understandable, and encouraging.

### 7.7 Adaptive support

The MVP uses explainable rules rather than machine learning:

```text
reviewPriority = incorrectAnswers
               + daysSinceLastPractice
               - (masteryLevel * masteryWeight)
```

The exact weight is configurable and must be covered by deterministic tests. Adaptive selection must not permanently hide content or create an unbounded repetition loop.

---

## 8. Content Specification

### 8.1 Letter content

Each letter record must include:

- Stable letter ID and uppercase display form.
- Lowercase display form.
- Letter-name audio asset.
- Primary phonics sound and audio asset.
- Three or more approved vocabulary references.
- Introduction prompt and mascot prompts.
- Recommended difficulty and world theme.

### 8.2 Vocabulary content

Each word record must include:

```text
word_id
display_name
normalized_word
starting_letter
model_or_image_asset
thumbnail_asset
pronunciation_audio
available_animations
category
difficulty
content_status
```

The current data layer uses `LetterData`, `WordData`, and data-driven `LessonData`. These remain the source of truth for lesson generation; UI widgets must not duplicate vocabulary facts.

### 8.3 Initial vocabulary

The content team must approve the final list for age suitability, cultural clarity, pronunciation, recognizability, and asset feasibility. The following is a starting set, not a locked editorial list:

| Letter | Suggested words |
|---|---|
| A | Apple, Ant, Airplane |
| B | Ball, Bear, Banana |
| C | Cat, Car, Cup |
| D | Dog, Duck, Drum |
| E | Egg, Elephant, Engine |
| F | Fish, Frog, Flower |
| G | Goat, Gift, Grape |
| H | Hat, Hen, Horse |
| I | Ice, Igloo, Insect |
| J | Juice, Jet, Jacket |
| K | Kite, Key, Kangaroo |
| L | Lion, Leaf, Lamp |
| M | Moon, Monkey, Milk |
| N | Nest, Nose, Nurse |
| O | Octopus, Orange, Owl |
| P | Penguin, Pizza, Pig |
| Q | Queen, Quilt, Quail |
| R | Rabbit, Rocket, Rainbow |
| S | Sun, Star, Shoe |
| T | Tiger, Tree, Train |
| U | Umbrella, Unicorn, Up |
| V | Van, Violin, Volcano |
| W | Whale, Wheel, Watermelon |
| X | Xylophone, X-ray, Fox |
| Y | Yo-yo, Yacht, Yellow |
| Z | Zebra, Zoo, Zipper |

X requires special content review because common beginner words do not always begin with the /x/ sound. The lesson must clearly distinguish initial-letter matching from end-sound examples such as Fox.

### 8.4 Prompt and audio standards

- Prompts use simple, concrete language and one action verb.
- Professional recordings are preferred for letter names, phonics, and vocabulary.
- Audio filenames and IDs are stable and validated before release.
- Every required narration has a visual fallback or subtitle when subtitles are enabled.
- Background music ducks while narration or important feedback is playing.

---

## 9. World, Mascot, and Asset Requirements

### 9.1 Reusable world themes

| Theme | Example content |
|---|---|
| Forest | Bear, Bird, Fox, Tree |
| Farm | Cow, Duck, Goat, Hen |
| Playground | Ball, Kite, Slide |
| Home | Chair, Door, Lamp |
| Ocean | Fish, Octopus, Whale |
| Space | Moon, Rocket, Star |

Worlds are visual contexts, not separate gameplay systems. Object placement, challenge metadata, camera framing, and animation references are data-driven.

### 9.2 Pip the Parrot

Pip is the single primary guide for MVP. Pip must:

- Give concise instructions.
- Celebrate correct attempts without overstimulation.
- Offer a hint or replay when the child is stuck.
- Introduce transitions and lesson completion.
- Work with audio off through expressive visual animation and subtitles.

### 9.3 Asset pipeline

- Preferred 3D interchange format is glTF/GLB where supported by the selected renderer.
- Every interactive asset maps to an educational content ID; model filenames are not the game logic.
- Models must be tested for mobile texture memory, polygon count, material count, draw calls, animation cost, and loading time.
- Asset loading is asynchronous and must show a useful loading state.
- Shared assets should be cached or reused; unnecessary duplicate downloads are out of scope.
- If a renderer cannot meet the vertical-slice requirements, the product must support a 2.5D or image-based fallback without changing learning rules.

### 9.4 3D integration gate

`flutter_scene` is the preferred candidate from the product concept, but it is not currently declared in the project dependencies. Phase 1 must verify package maintenance, Flutter/Dart compatibility, Android/iOS support, touch hit testing, animation support, asset loading, and Web feasibility before it becomes a committed dependency. The learning domain must remain renderer-independent.

---

## 10. Functional Requirements

| ID | Requirement | Priority | Acceptance signal |
|---|---|---:|---|
| FR-001 | Create and select a local child profile | Must | Profile survives restart |
| FR-002 | Present all A-Z lessons | Must | 26 deterministic lesson definitions load |
| FR-003 | Support uppercase and lowercase letter representations | Must | Matching and display tests pass |
| FR-004 | Present letter-name and phonics audio | Must | Audio assets resolve and play/replay |
| FR-005 | Present at least three words per letter | Must | Content validation reports >=78 words |
| FR-006 | Render an interactive lesson scene | Must | Vertical slice loads on target devices |
| FR-007 | Select letters and objects with touch | Must | Hit testing works with forgiving target bounds |
| FR-008 | Provide positive correct-answer feedback | Must | Animation, audio or visual confirmation, reward |
| FR-009 | Provide supportive incorrect-answer feedback | Must | Retry remains available and progress is not removed |
| FR-010 | Support Letter Hunt, Object Hunt, Sound Match, Word Builder, and Review | Must | Each mode has a completed test flow |
| FR-011 | Support tap-based word building | Must | A child can complete every MVP word without dragging |
| FR-012 | Save progress locally | Must | Progress survives force quit and restart |
| FR-013 | Track per-letter and per-word performance | Must | Accuracy and attempt counts update correctly |
| FR-014 | Award and persist stars and rewards | Must | Duplicate completion cannot corrupt totals |
| FR-015 | Replay important instructions | Must | Replay control works during each relevant phase |
| FR-016 | Pause and resume a lesson | Must | Audio and timers restore safely |
| FR-017 | Offer parent progress and settings | Should | Adult gate and summary work offline |
| FR-018 | Adapt review selection to weak content | Should | Priority algorithm is deterministic and tested |
| FR-019 | Provide subtitles and reduced-motion settings | Should | Settings affect all supported surfaces |
| FR-020 | Synchronize across devices | Future | Explicitly excluded from MVP |

---

## 11. Technical Architecture

### 11.1 Layer boundaries

```text
Flutter application
  Presentation: screens, HUD, controls, accessibility
  Application: view models, routing, session coordination
  Domain: lesson controller, question engine, mastery, rewards
  Data: content definitions, repositories, local persistence
  Services: audio, analytics, asset loading, platform adapters
  Renderer adapter: scene, camera, hit testing, model animation
```

The domain layer must not import renderer-specific types. A scene object exposes an educational identifier such as `apple`; the lesson controller decides whether it is correct for the current question.

### 11.2 Current project alignment

The existing project uses:

- Provider for dependency injection and observable state.
- GoRouter for application navigation.
- `ContentRepository` for lesson content.
- `ProgressRepository` and `shared_preferences` for local progress.
- `SettingsRepository` for user preferences.
- `AudioService` and `audioplayers` for playback.
- `AnalyticsService` for privacy-reviewed product events.
- `LessonController`, `QuestionEngine`, `MasteryEngine`, and `RewardEngine` for lesson behavior.

New code should extend these ownership boundaries rather than creating competing global state or screen-local lesson rules.

### 11.3 Session state

At minimum, a lesson session tracks:

```text
profile_id
lesson_id
target_letter
current_phase
current_challenge_id
attempt_count
correct_count
hint_count
started_at
last_saved_at
earned_stars
completion_state
```

The state machine must reject duplicate submissions while feedback is processing and must be safe if the app is backgrounded during audio or animation.

### 11.4 Persistence

Local storage includes:

- Child profiles and selected profile.
- Letter progress and mastery level.
- Word progress and attempt statistics.
- Stars, unlocks, and earned rewards.
- Lesson history and last-resume information.
- Audio, subtitle, music, effects, and reduced-motion settings.

Writes should be atomic at the repository boundary. Corrupt or missing records must fall back to safe defaults without preventing the app from opening.

### 11.5 Renderer adapter

The renderer adapter owns scene creation, camera framing, asset loading, object registration, hit testing, and visual animation. It does not own question generation, correctness, mastery, rewards, or persistence.

Required adapter capabilities:

- Load and unload a lesson scene asynchronously.
- Register interactive IDs and hit regions.
- Highlight or animate a selected object.
- Apply guided camera changes.
- Report renderer and asset errors to the application layer.
- Expose a non-3D fallback for tests and unsupported platforms where practical.

---

## 12. Mastery, Rewards, and Unlocks

### 12.1 Mastery levels

| Level | Meaning |
|---:|---|
| 0 | Not started |
| 1 | Introduced |
| 2 | Developing |
| 3 | Learned |
| 4 | Mastered |

Mastery is calculated from repeated performance, not a single answer. Signals include correct letter recognition, sound matching, object association, word building, hint usage, and review performance.

### 12.2 MVP mastery rule

The exact thresholds are configurable, but the default must be explainable and deterministic. A suggested approach is:

```text
evidenceScore = weightedCorrectAnswers
              - weightedIncorrectAnswers
              - weightedHints
              + repetitionBonus

masteryLevel = clamp(scoreToLevel(evidenceScore), 0, 4)
```

The system must prevent one unusually strong session from permanently marking a letter mastered.

### 12.3 Rewards

- Stars are the primary reward and are earned for completed challenges or lessons.
- Stars are never removed for incorrect answers or abandoned lessons.
- Secondary rewards may include stickers, mascot accessories, toys, or world decorations.
- Reward presentation should be celebratory but skippable and not dependent on scarcity, randomization, or purchases.
- Duplicate reward grants must be idempotent.

### 12.4 Unlocks

Lessons unlock through clear progress rules. The first lesson must be immediately available. A child may replay earlier lessons at any time. Unlock requirements must be stored as data and must not make the child repeat a mastered lesson unnecessarily.

---

## 13. Accessibility and Child-Centered UX

- Minimum touch targets should follow platform accessibility guidance and be expanded around small visual objects.
- Every important audio instruction has a replay control.
- Visual feedback accompanies audio feedback; color is never the sole signal.
- Subtitles are optional but available for important prompts and narration.
- Reduced-motion mode limits camera movement, object bouncing, and celebration intensity without hiding state.
- Word Builder always supports tap selection.
- Text uses high contrast, large sizes, clear letterforms, and short phrases.
- The app remains usable with music muted and with narration muted where visual alternatives exist.
- Avoid timers, countdowns, lives, punitive sounds, flashing failure states, and forced reading.
- The child-facing experience must not expose external links, purchases, social features, or profile deletion.

---

## 14. Audio and Media Requirements

### 14.1 Audio categories

| Category | Examples |
|---|---|
| Educational voice | Letter names, phonics, word pronunciations, prompts |
| Mascot voice | Welcome, hints, encouragement, transitions |
| Effects | Tap, correct, retry, reward, unlock |
| Music | World loops, menu loop, completion sting |
| Environment | Optional, quiet world ambience |

### 14.2 Playback behavior

- Narration pauses or ducks background music.
- Replay stops or safely replaces the previous narration instance.
- Audio failures do not block the child from completing a visual challenge.
- Settings control music, effects, and voice independently.
- Audio assets are preflighted for existence, duration, format, and volume consistency.

### 14.3 Visual assets

The app uses reusable world, mascot, UI, avatar, and object assets. A content validation tool should report missing references before release. The vertical slice must be playable with production-like assets, not placeholder boxes alone.

---

## 15. Privacy, Safety, and Data Governance

- Collect the minimum information needed to run local profiles and progress.
- Do not require a child account, email, precise location, contacts, camera, microphone, or public identity for MVP.
- Do not include targeted advertising, public chat, user-generated links, or social discovery.
- Keep child profiles and learning history local for MVP.
- Put analytics behind a privacy-reviewed service boundary and make event payloads non-identifying.
- Require an adult gate for parent settings, reset/delete operations, external links, and any future commercial action.
- Maintain a data inventory, retention policy, deletion behavior, and platform privacy disclosures before release.
- Obtain legal review for the target distribution markets before store submission.

---

## 16. Analytics and Observability

Analytics are for product quality and learning improvement, not advertising profiling. Candidate events are:

```text
app_opened
profile_selected
lesson_started
lesson_phase_started
challenge_presented
challenge_answered
challenge_completed
hint_used
audio_replayed
lesson_paused
lesson_abandoned
lesson_completed
reward_unlocked
settings_changed
asset_load_failed
```

Event payloads may include anonymous session identifiers, lesson ID, letter ID, challenge type, result, duration bucket, and app version. They must not include child names, free-form text, exact location, or unnecessary device identifiers.

The app should log actionable local diagnostics for missing content, audio failures, scene-load failures, and persistence errors without exposing technical details to the child.

---

## 17. Performance and Reliability

| Area | Requirement |
|---|---|
| Frame rate | Target 60 FPS; minimum acceptable 30 FPS on supported mid-range devices |
| Input response | Immediate visual acknowledgement after a valid tap |
| Scene loading | Preferably under 3 seconds after required assets are available |
| Audio | No blocking UI while audio loads or changes track |
| Memory | No steady growth across repeated lesson entry and exit |
| Offline use | Core lessons, audio, progress, and settings work without network |
| Recovery | App can reopen after interruption without corrupting progress |
| Crash-free sessions | Release target >=99.5% |
| Battery and thermals | No sustained excessive load during an ordinary lesson |

Performance testing must cover low, medium, and high graphics profiles if quality scaling is introduced. Quality selection should be automatic or adult-controlled, not a required child decision.

---

## 18. Quality Strategy and Acceptance Tests

### 18.1 Automated tests

- Content validation: all letters, words, audio references, and lesson IDs are valid.
- Question engine: correct, incorrect, distractor, and empty-content cases.
- Lesson controller: phase transitions, duplicate submission protection, retry behavior, and completion.
- Mastery engine: deterministic updates across repeated attempts.
- Reward engine: idempotent grants and persistence.
- Repository layer: save, load, reset, and corrupt-data fallback.
- Audio service: replay, interruption, ducking state, and missing-file fallback.
- Accessibility settings: subtitles and reduced-motion behavior.

### 18.2 Widget and integration tests

- App boot and route transitions.
- Profile creation and selection.
- Lesson start, challenge completion, pause, resume, and completion.
- Progress survives restart.
- Parent gate protects adult routes.
- Settings change the relevant services and widgets.

### 18.3 Device and usability tests

- Android and iOS phones across supported screen sizes.
- Portrait and landscape behavior if both are supported; otherwise enforce the chosen orientation consistently.
- Slow storage and cold asset load.
- Backgrounding during narration, animation, and persistence.
- Muted audio, reduced motion, subtitles, and large text settings.
- A moderated child usability session with the A-C vertical slice.

### 18.4 Letter lesson acceptance criteria

A letter lesson is production-ready when:

- Uppercase and lowercase representations display correctly.
- Letter name and phonics audio play and can be replayed.
- At least three approved vocabulary associations are available.
- Required assets load or fail gracefully with a usable fallback.
- Interactive targets respond to child-sized taps.
- Correct answers provide visual and audio feedback.
- Incorrect answers allow another attempt without loss of progress.
- At least one word-building activity can be completed by tapping.
- Progress, stars, attempts, and mastery update correctly.
- The lesson can be paused, resumed, completed, and reopened.
- The lesson meets supported-device performance targets.

---

## 19. Delivery Plan

| Phase | Deliverable | Exit gate |
|---:|---|---|
| 1 | Technical prototype | Renderer, touch hit testing, audio, asset loading, and fallback validated |
| 2 | A-C vertical slice | One complete lesson loop works with production-like content |
| 3 | Reusable lesson framework | Data-driven challenges, persistence, mastery, and rewards tested |
| 4 | Core child UX | Profile, map, game, completion, pause, settings, and parent gate complete |
| 5 | Content production | A-Z and 78+ words validated by content and audio review |
| 6 | Progress and adaptive review | Mastery, unlocks, history, and weak-letter review stable |
| 7 | Performance and accessibility | Device matrix, reduced motion, subtitles, and loading behavior pass |
| 8 | Beta validation | Child usability, parent feedback, crash and analytics review |
| 9 | Store readiness | Privacy review, content sign-off, release assets, and platform checks complete |

### 19.1 Vertical slice contents

The A-C slice includes:

- Apple, Ant, Airplane.
- Ball, Bear, Banana.
- Cat, Car, Cup.
- One reusable world with data-driven object placement.
- Letter Hunt, Object Hunt, Sound Match, Word Builder, and Review.
- Pip prompts, learning audio, feedback audio, stars, and local persistence.

The slice must answer these questions before scaling content:

1. Can a child complete the loop without reading?
2. Are the scene renderer and hit targets reliable on target devices?
3. Are audio and animation timing clear rather than distracting?
4. Can content creators add a new letter without editing gameplay code?
5. Does the child understand retry feedback as encouragement?

---

## 20. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| 3D renderer incompatibility or instability | High | Validate early; keep renderer adapter and fallback path |
| Asset production exceeds MVP capacity | High | Reuse six themes; gate A-C before A-Z production |
| Audio licensing or recording inconsistency | High | Establish naming, review, and loudness standards early |
| Child cannot understand the next action | High | Test with children; prioritize voice, animation, and one-task screens |
| Large scenes reduce performance | High | Load only current objects; profile memory, draw calls, and frame rate |
| Adaptive review feels repetitive | Medium | Cap repeats, explain priority, and preserve variety |
| Progress corruption or accidental reset | High | Atomic repository writes, backups where appropriate, reset confirmation |
| Privacy requirements change by market | High | Legal review before analytics, accounts, sync, or store release |
| Phonics examples are ambiguous | Medium | Editorial and speech review, especially for Q, X, and regional variants |

---

## 21. Open Decisions

These decisions must be resolved before the related milestone is marked complete:

1. Which Flutter-compatible 3D renderer passes the Phase 1 gate, and is Web in scope for the first release?
2. Which six world themes receive final production assets first?
3. What is the approved recording voice, accent, and pronunciation guide?
4. Will the MVP ship portrait-only, landscape-only, or support both orientations?
5. What exact mastery thresholds and reward values best match the first usability study?
6. Which analytics, if any, are permitted in the initial release markets?
7. What minimum Android and iOS versions and device performance tiers are supported?
8. Does X use a special initial-letter lesson, an end-sound example, or a content exception?

---

## 22. Final MVP Experience

A child opens the app and Pip says, "Hi! Today we are learning B!"

The child enters a bright forest scene. A large **B** appears. The app says, "B says buh!" A Bear, Ball, Banana, Apple, and Cat are placed in the world.

The app asks, "Can you find something that starts with B?" The child taps the Bear. The Bear animates, the app says, "Bear! B-B-Bear starts with B!", and a star moves to the reward counter. The child continues through the Ball and Banana, matches the /b/ sound, builds a short word by tapping letter tiles, and completes a brief review.

Pip celebrates: "Fantastic! You learned B!" The lesson result is saved locally. The child can continue to the next adventure, replay the lesson, or leave and return later without losing progress.

That is the product promise: **an educational lesson hidden inside an enjoyable, accessible 3D adventure.**
