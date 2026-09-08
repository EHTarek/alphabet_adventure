# UI/UX Context

## Alphabet Adventure 3D

**Source:** [Product Requirements Specification](../PRS.md)  
**Companion document:** [Feature Contexts](FEATURE_CONTEXTS.md)  
**Status:** Design and implementation context for MVP  
**Audience:** Product design, Flutter engineering, content, QA, and usability research  
**Updated:** 2026-09-08

This document defines how Alphabet Adventure 3D should feel, look, and behave across the child and parent experiences. It is a design context, not a pixel-perfect screen specification. Concrete visual decisions should remain consistent with this document and the existing Flutter theme.

---

## 1. Experience Direction

Alphabet Adventure 3D should feel like a friendly storybook world that happens to teach early literacy. The interface is bright, tactile, expressive, and calm under pressure.

### Design promise

```text
See it -> Hear it -> Touch it -> Celebrate it -> Remember it
```

### Emotional qualities

- Warm rather than noisy.
- Playful rather than competitive.
- Clear rather than dense.
- Curious rather than instructional.
- Rewarding rather than addictive.
- Safe and forgiving rather than score-driven.

### Two audience modes

| Mode | Design priority |
|---|---|
| Child-facing | Recognition, audio guidance, large targets, one task, immediate feedback |
| Parent-facing | Scannable information, settings, progress interpretation, privacy clarity |

The child-facing interface should not look like a smaller version of the parent dashboard. They are different experiences with different information density and interaction expectations.

---

## 2. Existing Visual Foundation

The current Flutter implementation already establishes a visual foundation:

- Fredoka typography through `google_fonts`.
- A bright coral primary color.
- Turquoise, yellow, green, blue, orange, and purple accents.
- Sky and cream background surfaces.
- Large buttons with a minimum height around 56-60 logical pixels.
- Rounded cards and dialogs.
- Shared widgets for mascot, animated letters, stars, rewards, audio replay, and interactive objects.
- Flutter Animate-based motion utilities.

### Directional guidance

Keep the existing friendly palette and Fredoka personality, but use color with discipline. Coral, turquoise, and warm yellow should establish the brand; green should communicate success; orange should communicate retry or attention without resembling failure. Purple and blue are supporting world accents, not the default color of every screen.

The design system should avoid relying on gradients, shadows, or rounded containers to communicate hierarchy. Use spacing, typography, composition, shape, and motion first.

---

## 3. Child UX Principles

### 3.1 One action

Every child screen has one primary action. Secondary actions are quiet, icon-led, or available through a simple pause control.

### 3.2 Audio first, visuals always

Spoken guidance leads the experience, but visual state must remain understandable when audio is muted. Important prompts should have subtitles or visual symbols when enabled.

### 3.3 Touch should feel generous

- Use large visible controls.
- Expand hit areas around small objects.
- Keep targets stable while hovered, pressed, or animated.
- Avoid precise drag requirements in MVP.
- Do not place critical controls near system gesture areas.

### 3.4 Feedback should be immediate

A valid tap should produce a visual response immediately, even if the full audio or celebration is still loading. Use a short response hierarchy:

```text
Tap -> highlight -> sound/voice -> object animation -> reward
```

### 3.5 No shame states

Do not use red full-screen error states, lives, countdowns, score loss, harsh buzzes, or language that labels the child as wrong. A retry state should look like an invitation to continue.

### 3.6 Repetition needs variation

Repeated practice can change the camera framing, mascot phrasing, object arrangement, or sound effect while preserving the same educational target. Variation should support attention, not introduce confusion.

---

## 4. Information Architecture

### Child journey

```text
Splash
  -> Profile selection
  -> World map
  -> Lesson introduction
  -> Object/letter challenge
  -> Mini-game
  -> Review
  -> Lesson complete
  -> World map
```

### Adult journey

```text
Child-facing screen
  -> Pause or settings entry
  -> Adult gate
  -> Parent dashboard
  -> Progress or settings
  -> Return to child flow
```

### Navigation rules

- Child navigation is primarily forward and guided.
- The world map is the child’s home base.
- Back navigation during an active challenge pauses before leaving.
- Adult routes are not discoverable as large child-facing actions.
- Every exit from a lesson has a predictable result: save the safe checkpoint, then leave or resume.

---

## 5. Screen Contexts

### 5.1 Splash and loading

### Purpose

Establish the world and prepare local services without making the child wait on technical complexity.

### Composition

- Pip or logo as the visual anchor.
- Gentle background world cue.
- Small, clear loading indicator only when needed.
- Optional short welcome audio.

### States

- First launch.
- Returning launch.
- Content validation in progress.
- Recoverable loading failure.

### UX rules

- Use a short, calm animation loop.
- Never show a blank screen.
- If loading takes longer than expected, explain the wait in child-friendly language and provide an adult-facing diagnostic only behind the gate.

---

### 5.2 Profile selection

### Purpose

Let a child identify their profile through visual recognition.

### Layout

- Large avatar choices in a spacious grid or horizontal arrangement.
- Nicknames shown as supporting labels, not the only identifier.
- One prominent Continue action after selection.
- Adult management access kept small and secondary.

### Interaction

- Tapping an avatar previews selection through scale, glow, or Pip response.
- The selected profile remains visually stable.
- Creation uses a short, low-reading flow.

### Empty state

Show one welcoming Create Profile action with Pip guidance. Do not show a settings-heavy form.

---

### 5.3 World map

### Purpose

Turn progression into a visual journey and make the next lesson obvious.

### Composition

- Full-width illustrated or scene-inspired background.
- A clear path of letter destinations.
- Each destination has a stable visual tile or landmark.
- Current lesson is the strongest visual focus.
- Stars and progress sit in a quiet top-level HUD.

### Lesson states

| State | Visual treatment | Interaction |
|---|---|---|
| Not started | Muted but recognizable landmark, lock or future cue | Explain availability gently |
| Available | Bright landmark with clear invitation | Start lesson |
| In progress | Progress marker and partial reward | Resume or replay |
| Completed | Star/result marker | Replay |
| Mastered | Distinct badge or celebration detail | Replay and review |

Do not communicate these states with color alone. Pair color with icons, patterns, labels, or shape.

### Child action hierarchy

1. Start or resume recommended lesson.
2. Select another available lesson.
3. Open pause/settings.

---

### 5.4 Lesson introduction

### Purpose

Create a memorable first encounter with one letter and its sound.

### Composition

- Large uppercase letter as the hero element.
- Lowercase partner nearby or revealed through a simple transformation.
- Pip positioned as guide, never blocking the letter.
- First vocabulary object enters with a clear visual relationship.
- Replay control remains visible.

### Motion

Use one meaningful entrance animation for the letter and one for the example object. Avoid multiple simultaneous bouncing elements. Reduced-motion mode should keep the final arrangement visible and skip or shorten the motion.

### Primary action

A single Continue action appears only after the essential introduction is available. Audio can guide advancement, but the child must retain control.

---

### 5.5 Game screen and HUD

### Purpose

Keep the world and the learning target visually dominant while making support controls easy to find.

### Layout zones

```text
+------------------------------------------------+
| Pause       Lesson progress        Stars       |
|                                                |
|              3D / scene viewport              |
|                                                |
| Pip + prompt                         Replay    |
+------------------------------------------------+
```

The exact arrangement may adapt to portrait or landscape, but these responsibilities should remain stable:

- Pause is always reachable.
- Stars are visible but not the dominant focus.
- The scene occupies most of the screen.
- Pip and prompt are near the child’s attention path.
- Replay is visually consistent across lesson phases.

### Prompt presentation

- Use spoken instruction first.
- Keep visible text short, large, and supportive.
- If subtitles are enabled, show one prompt at a time.
- Avoid placing the prompt over an interactive object.

### Scene interaction

- Objects should have clear silhouettes and enough contrast from the background.
- Tap feedback should include a highlight or scale response before the full animation.
- Camera movement should be guided and bounded.
- Do not require the child to rotate or pan freely to find the answer in MVP.

---

### 5.6 Object Hunt and Letter Hunt states

### Ready state

The prompt is complete, the scene is stable, and tappable targets are visibly discoverable without excessive outlines.

### Pressed state

The selected object receives a brief, high-contrast response. The state must not move the object away from the finger or change its hit region.

### Correct state

- Selected object animates.
- Relevant letter and word relationship appears.
- Pip celebrates briefly.
- Star or progress feedback is visible.
- Next action becomes clear after the response.

### Retry state

- Keep the scene stable.
- Use a warm accent such as orange rather than red.
- Pip or a hint points attention without revealing everything immediately.
- The replay control remains available.

### Loading/error state

Keep a recognizable scene or fallback illustration visible. Use a simple child-safe message and an adult-accessible diagnostic path.

---

### 5.7 Sound Match and Word Match

### Composition

- Central audio or word cue.
- Two to four large choices.
- Generous spacing and stable tile dimensions.
- No competing decorative controls near the answer choices.

### Sound Match

Letters should be large enough to recognize by shape. The sound replay action should be adjacent to the prompt but visually distinct from answer choices.

### Word Match

Pair the spoken word with an object or initial letter. Avoid requiring the child to read the full word before hearing it.

### Choice feedback

Selected choices should visibly enter a processing state so the child understands why a second immediate tap is ignored.

---

### 5.8 Word Builder

### Composition

```text
Target picture and spoken word
              |
       Empty word slots
              |
       Letter tile tray
```

- Keep the target picture large and recognizable.
- Use fixed-size slots so the layout does not shift.
- Keep the tile tray within easy reach.
- Show the current partial word through letter shapes and optional spoken feedback.
- Include a simple reset or undo only if it is necessary and easy to understand.

### Tap interaction

Tapping a tile moves it to the next slot and gives immediate feedback. A correct tile may receive a quiet confirmation; an incorrect tile should return to the tray with supportive audio or visual guidance.

### Drag interaction

Drag is optional and must never be the only completion path. Drag previews should not obscure the target slots or cause accidental scrolling.

---

### 5.9 Lesson completion

### Purpose

Close the learning loop, make progress memorable, and return control to the child.

### Composition

- Pip and a celebratory but calm background treatment.
- Large star result or reward cluster.
- Letter and word recap.
- One primary Continue action.
- Replay and Return to Map as secondary actions.

### Motion

Use a short reward sequence such as a star flight or badge reveal. It should be skippable, safe in reduced-motion mode, and never delay navigation for long.

### Copy style

Use concrete, warm phrases:

- "You learned B!"
- "You found Bear."
- "Great listening!"
- "Let's explore another letter."

Avoid comparative or pressure-based phrases such as "Beat your score" or "Do not miss."

---

### 5.10 Parent dashboard

### Purpose

Give an adult a fast, useful interpretation of progress.

### Layout

- Quiet, denser layout than the child experience.
- Clear page title and active profile.
- Summary first: letters learned, words practiced, recent time.
- Letter progress section with filters or grouped states.
- Recent activity section.
- Settings and privacy entry points.

### Data visualization

Use labels, icons, counts, and short explanations. Charts are optional; avoid displaying misleading precision for small amounts of data.

Example status language:

- Not started.
- Getting familiar.
- Practicing.
- Learned.
- Review recommended.

### Parent actions

Reset, delete, external links, and future commercial actions must be visually and behaviorally distinct from ordinary progress browsing.

---

### 5.11 Settings

### Organization

Group settings into:

1. Audio: voice, music, effects.
2. Accessibility: subtitles, reduced motion, text support.
3. Profiles: manage profile, reset progress.
4. Privacy: local storage and analytics explanation.

### Interaction

Use toggles for binary settings, sliders or steppers for volume, and confirmation dialogs for destructive actions. Avoid burying important controls inside ambiguous menus.

---

## 6. Visual Design System Context

### 6.1 Typography

Use Fredoka as the child-facing display and body family to preserve the current product personality. Establish a clear type scale:

| Role | Use |
|---|---|
| Display | Hero letters and lesson celebration |
| Heading | Screen titles and parent section headings |
| Body | Prompts, explanations, and settings |
| Label | Buttons, status, and compact metadata |

Avoid using display-sized typography in dense parent cards or compact controls. Keep letter spacing neutral and let the typeface provide personality.

### 6.2 Color roles

| Role | Direction |
|---|---|
| Brand primary | Coral for primary action and identity |
| Support accent | Turquoise for exploration and secondary emphasis |
| Reward | Warm yellow for stars and celebration |
| Success | Green plus icon/shape confirmation |
| Retry/support | Orange plus encouraging copy |
| Information | Blue for neutral guidance |
| Surface | Sky, cream, and white for separation |
| Text | Dark charcoal for readable contrast |

Never use color as the only signal for mastery, correctness, locked state, or settings.

### 6.3 Shape language

- Rounded forms can make child controls feel approachable.
- Use a small number of consistent corner radii instead of making every element pill-shaped.
- Distinguish interactive controls from decorative cards through elevation, iconography, and behavior.
- Keep repeated lesson objects visually consistent in scale and framing.

### 6.4 Iconography

- Use familiar symbols for pause, replay, back, settings, and audio.
- Add accessible labels and tooltips for unfamiliar parent-facing icons.
- Use icon plus color plus text for mastery and settings where space allows.
- Do not replace the only instruction with an unexplained icon.

---

## 7. Motion and Audio Direction

### Motion principles

- Motion explains state or rewards attention.
- Use one focal animation at a time.
- Keep transitions short enough for a 3-8 minute lesson.
- Avoid perpetual motion in the HUD.
- Every important animated state has a reduced-motion equivalent.

### Recommended motion moments

- Letter entrance.
- Object highlight on tap.
- Pip reaction.
- Star movement to the counter.
- Lesson-complete reveal.
- Gentle map unlock.

### Audio principles

- Voice is the educational authority.
- Music ducks during voice prompts.
- Effects are short and non-startling.
- Retry audio is warm, never harsh.
- Replay is always easy to find.

---

## 8. Accessibility Context

### Motor

- Large touch targets.
- Forgiving object hit regions.
- Tap alternative for all drag interactions.
- Stable layouts that do not shift on press.
- No timed input requirement.

### Visual

- High contrast between text, controls, objects, and backgrounds.
- Clear silhouettes for interactive objects.
- Multiple signals for state: color, icon, shape, label, and motion.
- Large letterforms and short text.
- Support for device text scaling where it does not break the child task.

### Auditory

- Visual fallback for every important prompt.
- Subtitles for narration when enabled.
- Independent voice, effects, and music controls.
- Replay controls remain available.

### Cognitive and learning

- One task at a time.
- Predictable placement of replay and pause.
- Consistent prompt language.
- Short sessions and clear completion points.
- No punishment for exploration or mistakes.

### Reduced motion

Reduced-motion mode should:

- Replace camera movement with a stable framing change.
- Replace bouncing objects with a highlight or glow.
- Shorten celebration sequences.
- Preserve the same feedback and reward meaning.

---

## 9. Responsive and Platform Context

### Supported conditions

Design and test across:

- Small phone portrait.
- Large phone portrait.
- Tablet portrait or landscape if supported.
- Web viewport only after renderer validation.
- Safe areas, notches, system gesture areas, and keyboard appearance in parent forms.

### Responsive rules

- Preserve the primary action and learning target before preserving decoration.
- Use constrained content widths for parent screens.
- Keep scene objects within safe interaction bounds.
- Use stable aspect ratios for letter tiles, star counters, and answer choices.
- Do not let long labels overflow buttons or status chips.
- At narrow widths, stack content rather than shrinking text until it becomes hard to read.

### Orientation decision

The MVP must choose and document a primary orientation before the A-C vertical slice. The child game should not silently rotate between lesson phases. Parent screens may use responsive layouts within the chosen platform behavior.

---

## 10. Content and Microcopy Context

### Child-facing voice

- Short.
- Concrete.
- Positive.
- Present tense.
- One instruction at a time.

### Examples

| Situation | Recommended copy |
|---|---|
| Start | "Let's learn B!" |
| Letter name | "This is B." |
| Phonics | "B says buh." |
| Object hunt | "Find something that starts with B." |
| Correct | "Bear starts with B!" |
| Retry | "Let's try again." |
| Hint | "Listen one more time." |
| Completion | "You learned B!" |
| Loading | "Pip is getting the world ready." |
| Error | "That part is taking a break. Try again." |

Avoid sarcasm, shame, urgency, complex explanations, and comparative leaderboard language.

### Parent-facing voice

Parent copy can be more explicit but should remain concise. Explain what a mastery state means and distinguish an estimate from a precise measurement.

---

## 11. UI State and Component Contexts

Every reusable child-facing component should define at least:

```text
initial
loading
ready
pressed
disabled
success
retry
paused
reduced_motion
error
```

### Shared components

| Component | Required behavior |
|---|---|
| Audio replay button | Visible, stable, accessible, prevents duplicate playback |
| Star counter | Stable dimensions, animates only on actual award |
| Mascot widget | Supports idle, speaking, listening, celebrating, and hint states |
| Animated letter | Stable layout, uppercase/lowercase relationship, reduced-motion state |
| Interactive object | Registered ID, pressed, correct, retry, unavailable states |
| Reward animation | Skippable, idempotent, reduced-motion alternative |
| Primary child button | Large target, clear label, pressed/disabled state |
| Parent status row | Label, icon, value, and explanatory context |

### Component rules

- Do not place cards inside cards for child flows.
- Keep a component's interactive area larger than its visible decoration when necessary.
- Do not let loading indicators resize the component.
- Never use a disabled state where an explanation or retry state is more appropriate for the child.

---

## 12. Design QA Checklist

### Child flow

- [ ] A child can identify the next action without reading a paragraph.
- [ ] The current learning target is the visual focal point.
- [ ] Replay and pause controls are easy to find.
- [ ] Taps feel immediate and forgiving.
- [ ] Incorrect answers do not look like punishment.
- [ ] Celebration does not obscure the result or force continuation.

### Visual quality

- [ ] Text fits within its parent at supported sizes.
- [ ] Interactive objects remain stable during animation.
- [ ] The palette has clear role separation and sufficient contrast.
- [ ] Decoration does not compete with the educational target.
- [ ] Parent screens are denser and calmer than child screens.

### Accessibility

- [ ] Color is not the only state signal.
- [ ] Audio-off flow remains understandable.
- [ ] Reduced motion preserves meaning.
- [ ] Tap alternatives exist for all required interactions.
- [ ] Touch targets are suitable for young children.

### Product behavior

- [ ] Loading, success, retry, pause, and error states are designed.
- [ ] Progress is saved before leaving completion.
- [ ] Adult-only actions are protected.
- [ ] Missing media has a graceful fallback.
- [ ] The design matches the feature context and current route ownership.

---

## 13. Design Decisions To Resolve

1. Select the primary MVP orientation.
2. Approve the final renderer and define the 2.5D fallback surface.
3. Produce a small A-C visual kit before full-alphabet asset production.
4. Approve Pip's visual states and voice direction.
5. Define the final mastery visuals and status language with parent usability input.
6. Validate the current rounded-card and gradient treatment against child usability and accessibility testing.
7. Confirm the minimum device size and supported text scaling range.
