# Feature Contexts

## Alphabet Adventure 3D

**Source:** [Product Requirements Specification](../PRS.md)  
**Status:** Implementation context for MVP  
**Audience:** Product, design, engineering, QA, and content teams  
**Updated:** 2026-09-08

This document converts the PRS into feature-level contexts. Each context defines the user need, behavior, states, dependencies, analytics, and acceptance boundary for implementation.

---

## 1. Product Context

Alphabet Adventure 3D is an offline-first literacy game for children ages 4-8. The child learns through a guided loop:

```text
Choose profile
  -> Choose lesson
  -> Meet a letter
  -> Hear a prompt
  -> Explore and touch
  -> Receive encouragement
  -> Practice again
  -> Earn stars
  -> Save progress
```

The child experience must be simple enough to use without reading. The adult experience must make learning progress and settings understandable without exposing unnecessary child data.

### Global feature rules

- One primary child action is visible at a time.
- All important instructions have audio and a replay path.
- Incorrect answers never remove progress or rewards.
- Every challenge has a visible state for loading, ready, processing, correct, retry, and unavailable.
- Domain rules remain independent from the scene renderer and screen widgets.
- All progress is local-first and remains available without a network connection.
- Feature behavior must remain deterministic enough to test.

---

## 2. Feature Map

| ID | Feature | Primary user | MVP status | Main owner |
|---|---|---|---|---|
| F-01 | App bootstrap and splash | Child/adult | Must | App/application |
| F-02 | Child profiles | Child/adult | Must | Profile feature + progress repository |
| F-03 | World map and lesson unlocks | Child | Must | World map + mastery/reward |
| F-04 | Letter introduction | Child | Must | Lesson controller + audio |
| F-05 | Object Hunt | Child | Must | Question engine + renderer adapter |
| F-06 | Letter Hunt | Child | Must | Question engine + renderer adapter |
| F-07 | Sound Match | Child | Must | Question engine + audio |
| F-08 | Word Match | Child | Must | Question engine + content repository |
| F-09 | Word Builder | Child | Must | Question engine + word builder UI |
| F-10 | Review and adaptive support | Child | Must/Should | Mastery + question engine |
| F-11 | Feedback, hints, and audio replay | Child | Must | Audio service + shared widgets |
| F-12 | Lesson completion and rewards | Child | Must | Reward and mastery engines |
| F-13 | Progress persistence and resume | Child/adult | Must | Progress repository |
| F-14 | Parent dashboard | Adult | Should | Parent feature |
| F-15 | Settings and accessibility | Adult/child | Should | Settings repository + app theme |
| F-16 | Content and asset validation | Team | Must before release | Content pipeline |
| F-17 | Analytics and diagnostics | Team | Privacy-reviewed | Analytics service |
| F-18 | 3D scene integration | Child | Prototype gate | Renderer adapter |

---

## 3. F-01: App Bootstrap and Splash

### User need

The child should see a welcoming, understandable loading state while the app prepares local content, audio, settings, and profile state.

### Entry and exit

- Entry: Application launch.
- Exit: Active profile, profile selection, or world map based on local state.
- Failure exit: A child-safe recovery state with retry or offline continuation where possible.

### Behavior

1. Show the Alphabet Adventure mark and Pip.
2. Initialize repositories and settings.
3. Validate required bundled content references.
4. Load the selected profile state.
5. Route without waiting on optional analytics or network work.

### States

- `loading`: Bootstrapping is in progress.
- `ready`: Routing decision is available.
- `degraded`: Optional service failed, but core learning can continue.
- `error`: Required local content or storage cannot initialize.

### Acceptance criteria

- Cold launch reaches a usable route without network access.
- A missing optional asset does not cause an infinite spinner.
- Required initialization errors expose a retry path and a diagnostic log.
- The splash screen does not expose technical error details to the child.

---

## 4. F-02: Child Profiles

### User need

A child should be able to choose a familiar avatar and resume their own learning without entering sensitive personal information.

### MVP data

```text
profile_id
nickname
avatar_id
created_at
last_active_at
is_active
```

### Behavior

- Show existing profiles as large visual choices.
- Allow creation with a nickname or child-safe label and avatar.
- Make the active profile obvious through voice, highlight, or animation.
- Keep rename, delete, and profile management behind the parent area.
- Persist profile selection locally.

### States

- `empty`: No profiles exist; show the create-profile path.
- `selecting`: Existing profiles are available.
- `creating`: Profile details are being entered.
- `saving`: Profile is being persisted.
- `ready`: Profile is selected and can continue.
- `error`: Profile could not be saved; preserve entered values where safe.

### Acceptance criteria

- A profile can be created and selected offline.
- The selected profile survives app restart.
- No email, real name, birth date, microphone, camera, or network account is required.
- Profile deletion requires the adult gate and explicit confirmation.

### Dependencies

`ProfileViewModel`, `ProgressRepository`, avatar assets, local storage, adult gate.

---

## 5. F-03: World Map and Lesson Unlocks

### User need

The child needs a simple visual journey that shows what is available and what to try next.

### Behavior

- Present A-Z lessons as a readable visual path through reusable themes.
- Highlight one recommended next lesson.
- Allow replay of completed lessons.
- Represent locked, available, in-progress, completed, and mastered states using shape, icon, label, and motion as well as color.
- Keep unlock rules data-driven.

### Unlock model

- The first lesson is immediately available.
- Completing a lesson makes the next planned lesson available.
- Replay is always available for previously started lessons.
- Mastery does not remove access or require unnecessary repetition.

### States

- `loading`: Lesson definitions and progress are loading.
- `ready`: Map is interactive.
- `empty`: Content exists but no progress has been recorded.
- `updating`: A lesson result is being applied.
- `error`: Progress cannot be read; show a recoverable state.

### Acceptance criteria

- All 26 deterministic lesson definitions appear.
- Unlock state updates after completion without app restart.
- The child can distinguish available and locked lessons without color alone.
- Tapping a lesson produces a clear transition into the lesson or a gentle locked explanation.

### Dependencies

`LessonDefinitions`, `ContentRepository`, `WorldMapViewModel`, `ProgressRepository`, `MasteryEngine`, `RewardEngine`.

---

## 6. F-04: Letter Introduction

### User need

The child should meet one letter in a calm, memorable sequence before being asked to solve anything.

### Sequence

1. Display uppercase letter.
2. Introduce lowercase partner.
3. Speak the letter name.
4. Speak the primary phonics sound.
5. Present the first vocabulary example.
6. Offer replay and a single Continue action.

### States

- `preparing`: Letter and first word assets are loading.
- `presenting`: Guided presentation is active.
- `replayable`: Narration has completed and replay is available.
- `ready_to_continue`: Child can advance.
- `unavailable`: A missing asset is replaced by a visual fallback and diagnostic.

### Acceptance criteria

- Uppercase and lowercase forms are visually related.
- Letter name and phonics audio can be replayed independently where appropriate.
- The child is not required to read the prompt to continue.
- The introduction does not start a challenge until required assets are ready.

---

## 7. F-05: Object Hunt

### User need

The child should learn letter-to-word associations by finding a meaningful object in a world and receiving an immediate response.

### Behavior

- Speak a prompt such as "Find something that starts with B."
- Register scene objects by stable educational ID.
- Accept any valid target for the current question.
- On success, animate the object and speak the word and letter connection.
- On incorrect selection, keep the challenge active and offer retry support.

### States

- `loading_scene`
- `ready`
- `prompt_playing`
- `awaiting_selection`
- `processing_selection`
- `correct`
- `try_again`
- `hint_active`
- `paused`
- `asset_error`

### Acceptance criteria

- Valid objects have forgiving hit regions.
- Duplicate taps during processing do not produce duplicate rewards.
- Incorrect taps do not advance the phase or remove progress.
- The scene can be replaced by a test/fallback surface without changing correctness logic.
- A child can complete the challenge with audio muted when visual fallback is enabled.

### Dependencies

`QuestionEngine`, `LessonController`, renderer adapter, `InteractiveObject`, `AudioService`, and vocabulary content.

---

## 8. F-06: Letter Hunt

### User need

The child should recognize the target letter by finding it in the scene or selecting it from a small set of choices.

### Behavior

- Speak a prompt such as "Find the letter B."
- Show a small, age-appropriate set of letter choices.
- Support uppercase, lowercase, or matching pairs according to lesson difficulty.
- Use visually distinct distractors early in progression.
- Highlight the selected letter before correctness feedback completes.

### States

- `loading_scene`
- `ready`
- `prompt_playing`
- `awaiting_selection`
- `processing_selection`
- `correct`
- `try_again`
- `hint_active`
- `paused`
- `asset_error`

### Acceptance criteria

- Letter choices have stable dimensions and forgiving hit regions.
- Duplicate taps during processing do not produce duplicate rewards.
- Incorrect taps do not advance the phase or remove progress.
- Uppercase/lowercase matching follows the lesson difficulty configuration.
- The child can complete the challenge with audio muted when visual fallback is enabled.

### Dependencies

`QuestionEngine`, `LessonController`, renderer adapter, `AnimatedLetter`, `AudioService`, and letter content.

---

## 9. F-07: Sound Match

### User need

The child should connect a spoken phonics sound to the corresponding letter without needing to read phonetic notation.

### Behavior

- Play the target phonics sound.
- Present two to four large letter choices.
- Keep the replay control adjacent to the prompt and separate from answers.
- Speak and visually show the correct letter after success.

### Acceptance criteria

- Prompt audio can be replayed.
- Choice count is small enough for the child to scan.
- Distractors are visually distinct and pronunciation-safe.
- The feedback identifies the correct letter after success.
- Phonics assets are validated before the lesson becomes available.

### Dependencies

`QuestionEngine`, `LessonController`, `AudioService`, letter content, and answer-choice widgets.

---

## 10. F-08: Word Match

### User need

The child should connect a spoken vocabulary word to its object or starting letter.

### Behavior

- Speak or reveal the vocabulary word.
- Ask the child to select the matching object or initial letter.
- Present spoken support before expecting the child to use written text.
- Reinforce the complete letter-to-word relationship after success.

### Acceptance criteria

- Prompt audio can be replayed.
- Choices are large, stable, and easy to scan.
- Distractors are valid, pronounceable, and not accidentally ambiguous.
- The feedback identifies the correct letter and word after success.
- Word pronunciation assets are validated before the lesson becomes available.

### Content risks

Q, X, and regional pronunciation differences require editorial review. X must not imply that every X vocabulary example begins with the /x/ sound.

### Dependencies

`QuestionEngine`, `LessonController`, `AudioService`, `WordData`, and object/letter answer widgets.

---

## 11. F-09: Word Builder

### User need

The child should connect individual letters to a complete spoken word without needing handwriting or precise dragging.

### Behavior

- Show a target image and speak the word.
- Present a small set of letter tiles.
- Support tap-to-select as the primary interaction.
- Optionally support drag-and-drop where it is reliable.
- Provide immediate placement feedback.
- Celebrate when the word is complete and speak the whole word.

### States

- `introducing_word`
- `awaiting_tile`
- `tile_selected`
- `partial_word`
- `incorrect_order`
- `completed`
- `try_again`

### Rules

- A wrong tile does not remove already placed correct tiles unless the child chooses to reset.
- The child can hear the target word again.
- Tiles have stable dimensions and do not shift the layout when selected.
- Words are generally three to five letters for MVP.

### Acceptance criteria

- Every MVP word can be completed using taps only.
- The child can identify the current partial word visually and audibly.
- Completion is idempotent and awards one result.
- The word builder works with reduced motion and subtitles enabled.

---

## 12. F-10: Review and Adaptive Support

### User need

The child should revisit weak content without feeling punished or trapped in repetition.

### Behavior

- Select from introduced content, weighting lower accuracy and longer time since practice.
- Mix letter, sound, object, and word activities.
- Cap repeated exposure to one item in a session.
- Offer hints after difficulty while preserving the chance to answer independently.
- Record review performance separately from the presentation phase.

### Minimum review record

```text
content_id
attempts
correct_attempts
incorrect_attempts
hints_used
last_practiced_at
mastery_level
```

### Acceptance criteria

- Review selection is deterministic for a fixed progress state and seed.
- A weak letter receives more practice over time.
- Review cannot produce an endless loop of the same question.
- Hints improve support without subtracting stars or mastery already earned.

---

## 13. F-11: Feedback, Hints, and Audio Replay

### Feedback hierarchy

1. Immediate visual response.
2. Short sound effect.
3. Spoken reinforcement.
4. Reward animation or progress update.

### Correct response

Use a distinctive but calm success animation, speak the letter/word relationship, and continue only after the child has had time to perceive the response.

### Retry response

Use warm language such as "Let's try again" or "You are close." Avoid red failure surfaces, harsh sounds, score loss, or a full-screen interruption.

### Hint behavior

A hint may:

- Spotlight the relevant object.
- Replay the instruction.
- Reduce the choice set.
- Show a subtle letter or word cue.

### Acceptance criteria

- Replay is visible during every important prompt.
- Replay does not stack duplicate audio instances.
- Feedback remains understandable with music muted.
- Feedback is not dependent on color alone.

---

## 14. F-12: Lesson Completion and Rewards

### User need

The child should clearly understand that a lesson is complete and feel proud without being pressured to continue.

### Behavior

- Calculate earned stars once.
- Update letter and word mastery.
- Persist lesson completion before navigation.
- Show learned letters and words.
- Offer Continue, Replay, and Return to Map.
- Present secondary rewards only when they add meaning; avoid reward overload.

### States

- `calculating`
- `celebrating`
- `saved`
- `save_error`
- `ready_to_continue`

### Acceptance criteria

- Duplicate navigation cannot award duplicate stars.
- Completion survives force quit after the save boundary.
- A child can exit after completion without being forced into another lesson.
- The result appears in the map and parent dashboard.

---

## 15. F-13: Progress Persistence and Resume

### User need

A family should be able to close the app at any time without losing meaningful learning progress.

### Persistence boundaries

Save:

- Profile creation and selection.
- Completed challenge results.
- Lesson completion and earned stars.
- Mastery changes.
- Settings changes.
- Safe resume point when leaving mid-lesson.

Do not persist a partially submitted answer as correct.

### Recovery rules

- Missing values use safe defaults.
- Corrupt records are isolated and logged.
- A failed write must not overwrite the last valid progress snapshot.
- Reset/delete operations are adult-only and explicit.

### Acceptance criteria

- Progress survives app restart and offline use.
- Backgrounding during narration does not corrupt the lesson.
- Reopening a lesson resumes or restarts according to a documented, consistent rule.
- Storage failure produces a recoverable adult-facing message.

---

## 16. F-14: Parent Dashboard

### User need

An adult should understand learning progress quickly without needing to inspect every lesson.

### Dashboard content

- Active profile.
- Letters grouped by not started, introduced, developing, learned, and mastered.
- Words practiced and words needing review.
- Accuracy trend using plain language.
- Recent practice sessions and approximate time.
- Stars and rewards earned.
- Settings and profile management entry points.

### Adult gate

The gate must be easy for an adult and difficult for a young child to pass accidentally. It must not rely only on a hidden button or a child-readable password.

### Acceptance criteria

- Parent content is inaccessible from the child flow without the gate.
- Dashboard works offline.
- Status uses labels and icons as well as color.
- No unnecessary child identity or raw event payload is displayed.

---

## 17. F-15: Settings and Accessibility

### Settings

- Voice volume.
- Music volume.
- Effects volume.
- Subtitles on/off.
- Reduced motion on/off.
- Profile management.
- Privacy and data explanation.
- Reset/delete profile behind confirmation.

### Behavior

Settings apply consistently across screens and lessons. A changed setting should provide immediate, observable feedback where safe.

### Acceptance criteria

- Music, effects, and voice can be controlled independently.
- Subtitles expose important educational prompts.
- Reduced motion removes nonessential motion without hiding state.
- Settings persist across restart.

---

## 18. F-16: Content and Asset Validation

### Required validation

Before content is considered release-ready, validate:

- 26 unique letter records.
- Uppercase/lowercase pairs.
- At least 78 approved vocabulary records.
- Stable word and lesson IDs.
- Existing audio, image, and scene references.
- Valid challenge options and distractors.
- No duplicate rewards or lesson IDs.
- Pronunciation and editorial approval status.

### Failure handling

Validation should fail the build or release checklist for missing required content. It should produce a human-readable report grouped by letter and asset category.

---

## 19. F-17: Analytics and Diagnostics

### Product events

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

### Rules

- Events are non-identifying and privacy-reviewed.
- Child names, free-form text, exact location, contacts, and unnecessary device identifiers are excluded.
- Analytics failures never block gameplay.
- Local diagnostics capture missing content, audio errors, scene errors, and persistence errors.

---

## 20. F-18: 3D Scene Integration

### Prototype gate

Before adopting a renderer as a production dependency, verify:

- Flutter/Dart compatibility.
- Android and iOS support.
- Touch hit testing.
- glTF/GLB loading.
- Animation playback.
- Guided camera control.
- Scene load and unload behavior.
- Memory and frame-rate profile.
- Web feasibility, if Web remains in scope.
- Test/fallback strategy.

### Boundary

The renderer owns visual scene state. The domain owns learning state. A 3D object reports an educational ID such as `apple`; it does not decide whether that object is correct.

### Fallback

If the renderer fails the prototype gate, use a 2.5D or image-based interaction layer while preserving the same lesson controller, questions, content IDs, progress, audio, and reward behavior.

---

## 21. Cross-Feature State Model

Every child interaction should be representable with these state categories:

```text
uninitialized
loading
ready
prompting
awaiting_input
processing
correct
retry
hinted
paused
completed
error
```

### State transition rules

- `loading -> ready` only after the required content for the current action is available.
- `awaiting_input -> processing` on the first accepted interaction.
- `processing` ignores duplicate input.
- `processing -> correct` or `retry` after correctness evaluation.
- `retry -> awaiting_input` after feedback is perceived or dismissed.
- `completed` persists before navigation.
- `error` must expose a recovery path and preserve the last valid state.

---

## 22. Cross-Feature Acceptance Checklist

### Child experience

- [ ] A child can start a lesson without reading a menu.
- [ ] One obvious primary action is visible at each step.
- [ ] Every prompt can be replayed.
- [ ] Incorrect answers are supportive and non-punitive.
- [ ] Tap targets are forgiving and stable.
- [ ] Audio-off and reduced-motion states remain usable.

### Learning integrity

- [ ] The letter, sound, word, and object relationship is correct.
- [ ] Distractors are valid and not ambiguous.
- [ ] Mastery is based on repeated evidence.
- [ ] Review prioritizes weak content without endless repetition.

### Engineering integrity

- [ ] Domain logic is renderer-independent.
- [ ] Progress writes are safe and recoverable.
- [ ] Duplicate submissions and duplicate rewards are prevented.
- [ ] Missing optional assets do not block the lesson.
- [ ] Required assets are validated before release.

### Privacy and adult experience

- [ ] Parent-only actions are gated.
- [ ] No unnecessary personal data is collected.
- [ ] Analytics are non-identifying and optional to gameplay.
- [ ] Adult-facing reset and deletion behavior is explicit.
