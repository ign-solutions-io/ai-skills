---
name: react-best-practices
description: Preferred patterns for writing React code, favoring explicit event-driven logic and derived state over implicit synchronization via useEffect ("you might not need an effect"). Use when writing, reviewing, or refactoring React components, hooks, or effects, when deciding how to manage component state or data fetching, or when the user asks to apply React best practices or audit useEffect usage.
---

# React Best Practices: You Might Not Need an Effect

These are **preferred patterns** for writing new React code. Apply them when the opportunity naturally arises — when writing new components, modifying existing logic, or making decisions about state management. **Do not** proactively rewrite existing code solely to align with these guidelines; focus on applying them where they fit the work at hand.

The overall direction favors **explicit event-driven logic** over **implicit synchronization** via `useEffect`.

---

## Guideline 1: Prefer Derived State Over Synced State

Most effects that set state from other state are unnecessary and add extra render cycles.

```typescript
// ❌ BAD: Two render cycles - first stale, then filtered
function ProductList() {
  const [products, setProducts] = useState([]);
  const [filteredProducts, setFilteredProducts] = useState([]);

  useEffect(() => {
    setFilteredProducts(products.filter((p) => p.inStock));
  }, [products]);
}

// ✅ GOOD: Compute inline in one render
function ProductList() {
  const [products, setProducts] = useState([]);
  const filteredProducts = products.filter((p) => p.inStock);
}
```

**Smell test:**

- You are about to write `useEffect(() => setX(deriveFromY(y)), [y])`.
- You have state that only mirrors other state or props.

> **Note:** If the calculation is expensive (e.g., filtering thousands of items), use `useMemo(() => ..., [deps])` instead of an Effect.

---

## Guideline 2: Prefer Data-Fetching Libraries

Effect-based fetching often creates race conditions and duplicated caching logic.

```typescript
// ❌ BAD: Race condition risk
function ProductPage({ productId }) {
  const [product, setProduct] = useState(null);
  useEffect(() => {
    fetchProduct(productId).then(setProduct);
  }, [productId]);
}

// ✅ GOOD: Query library handles cancellation/caching/staleness
function ProductPage({ productId }) {
  const { data: product } = useQuery(['product', productId], () =>
    fetchProduct(productId)
  );
}
```

**Smell test:**

- Your effect does `fetch(...)` and then `setState(...)`.
- You are re-implementing caching, retries, cancellation, or stale handling.

---

## Guideline 3: Prefer Event Handlers Over Effects

When a user interaction triggers work, prefer doing it in the handler. Effects are better suited for code that runs because the component was displayed, not because of a specific interaction.

```typescript
// ❌ BAD: Effect as an action relay
function LikeButton() {
  const [liked, setLiked] = useState(false);
  useEffect(() => {
    if (liked) {
      postLike();
      setLiked(false);
    }
  }, [liked]);
  return <button onClick={() => setLiked(true)}>Like</button>;
}

// ✅ GOOD: Direct event-driven action
function LikeButton() {
  const handleClick = () => {
    postLike();
  };
  return <button onClick={handleClick}>Like</button>;
}
```

**Smell test:**

- State is used as a flag so an effect can do the real action.
- You are building "set flag -> effect runs -> reset flag" mechanics.

---

## Guideline 4: Consider useMountEffect for One-Time External Sync

When you need a one-time setup on mount, consider wrapping `useEffect(..., [])` in a named hook to make intent explicit.

```typescript
function useMountEffect(callback: () => void | (() => void)) {
  useEffect(callback, []);
}

// ✅ GOOD: Mount only when preconditions are met
function VideoPlayerWrapper({ isLoading }) {
  if (isLoading) return <LoadingScreen />;
  return <VideoPlayer />;
}

function VideoPlayer() {
  useMountEffect(() => playVideo());
}
```

`useMountEffect()` function description and suggested usage.

```typescript
import { useEffect, useRef, EffectCallback } from 'react';

/**
 * A hook that runs an effect only once when the component mounts.
 * * Why use this instead of useEffect(fn, [])?
 * 1. Intent: It explicitly signals to other developers (and AI) that 
 * this is a one-time synchronization, not a reactive effect.
 * 2. Strict Mode: In React 18+, useEffect runs twice in development. 
 * While this hook still follows React's lifecycle, the naming helps 
 * differentiate "Initial Setup" from "Value Synchronization".
 * * @param effect The logic to run on mount. Can return a cleanup function.
 */
export function useMountEffect(effect: EffectCallback) {
  // We use a ref to ensure we can track if the effect has been initialized
  // if you need to strictly bypass the React 18 double-call (not usually recommended).
  // Standard implementation simply wraps the empty dependency array:
  
  useEffect(effect, []);
}

/* Usage Example:
  
  useMountEffect(() => {
    const handleScroll = () => console.log(window.scrollY);
    window.addEventListener('scroll', handleScroll);
    
    return () => window.removeEventListener('scroll', handleScroll);
  });
*/
```

**Smell test:**

- You are synchronizing with an external system (DOM, Browser API, 3rd party widget).
- The behavior is naturally "setup on mount, cleanup on unmount."

---

## Guideline 5: Prefer Key-Based Reset Over Dependency Choreography

When a component needs to "start fresh" for a new entity, prefer React's built-in `key` mechanism over an Effect that resets state.

```typescript
// ❌ BAD: Effect attempts to emulate remount behavior
function Profile({ userId }) {
  const [comment, setComment] = useState('');
  useEffect(() => {
    setComment('');
  }, [userId]);
}

// ✅ GOOD: key forces clean remount
function ProfilePage({ userId }) {
  return <Profile key={userId} userId={userId} />;
}
```

**Smell test:**

- You are writing an effect whose only job is to reset local state when an ID/prop changes.
- You want the component to behave like a brand-new instance for each entity.

---

## Guideline 6: Prefer Inline Computation Over Effect Chains

When possible, avoid "Effect Chains" where one Effect triggers a state change that triggers another. These tend to cause extra re-renders and can be hard to debug.

```typescript
// ❌ BAD: Chain of Effects (Procedural logic)
useEffect(() => { setA(x) }, [x]);
useEffect(() => { setB(a) }, [a]);

// ✅ GOOD: Calculate values during render
function Component({ x }) {
  const a = x * 2;
  const b = a + 1;
  return <div>{b}</div>;
}
```

**Smell test:**

- You have multiple Effects in a single component that depend on each other's state updates.
- You are treating Effects like a sequence of steps rather than a synchronization tool.

---

## Architecture Principles

These principles describe the direction we're moving toward. They're useful mental models when designing new components or rethinking existing ones.

### Forcing function for nesting

Favoring alternatives to direct `useEffect` encourages cleaner component tree design.

- Parents own orchestration and lifecycle boundaries.
- Children can assume preconditions are already met.

### Choose your bug

- **`useMountEffect` failures:** Usually binary and loud (it ran once, or not at all).
- **Direct `useEffect` failures:** Often degrade gradually and show up as flaky behavior, performance issues, or infinite loops.

### The Unix Philosophy

Each unit does one job, and coordination happens at clear boundaries (props and event handlers).
