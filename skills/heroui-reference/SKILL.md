---
name: heroui-reference
description: "HeroUI v3 React component reference. Activate when building UI components, creating pages, or styling with HeroUI. Covers all 75+ components, installation, theming, composition patterns, and import paths. Use this instead of building custom components."
---

# HeroUI v3 React Reference

> Source: https://heroui.com/react/llms.txt
> Full docs: https://www.heroui.com/docs/react/components

## Quick Start

### Installation

```bash
bun add @heroui/styles @heroui/react
```

### CSS Setup (globals.css)

Order matters — Tailwind first, then HeroUI:

```css
@import "tailwindcss";
@import "@heroui/styles";
```

### Requirements

- React 19+
- Tailwind CSS v4

## Import Pattern

All components are imported from `@heroui/react`:

```tsx
import { Button, Card, Modal, Input, Select, Table, Tabs } from "@heroui/react"
```

## Complete Component Catalog

### Buttons & Actions

| Component | Import | Description |
|-----------|--------|-------------|
| `Button` | `@heroui/react` | Clickable button with multiple variants and states |
| `ButtonGroup` | `@heroui/react` | Group related buttons with consistent styling |
| `CloseButton` | `@heroui/react` | Button for closing dialogs, modals, dismissing content |
| `ToggleButton` | `@heroui/react` | Interactive toggle for on/off states |
| `ToggleButtonGroup` | `@heroui/react` | Groups multiple ToggleButtons |

### Forms & Inputs

| Component | Import | Description |
|-----------|--------|-------------|
| `Input` | `@heroui/react` | Single-line text input |
| `TextField` | `@heroui/react` | Text field with labels, descriptions, validation |
| `TextArea` | `@heroui/react` | Multiline text input |
| `NumberField` | `@heroui/react` | Number input with increment/decrement buttons |
| `SearchField` | `@heroui/react` | Search input with clear button |
| `InputOTP` | `@heroui/react` | One-time password input for verification codes |
| `InputGroup` | `@heroui/react` | Group inputs with prefix/suffix elements |
| `Select` | `@heroui/react` | Collapsible list for selecting one option |
| `ComboBox` | `@heroui/react` | Text input + listbox with filtering |
| `Autocomplete` | `@heroui/react` | Select with filtering/search |
| `Checkbox` | `@heroui/react` | Single checkbox |
| `CheckboxGroup` | `@heroui/react` | Multiple checkbox selections |
| `RadioGroup` | `@heroui/react` | Single selection from a list |
| `Switch` | `@heroui/react` | Toggle switch for boolean states |
| `Slider` | `@heroui/react` | Select values within a range |
| `Form` | `@heroui/react` | Form validation and submission wrapper |
| `Fieldset` | `@heroui/react` | Group related form controls with legends |
| `Label` | `@heroui/react` | Accessible label for form controls |
| `Description` | `@heroui/react` | Supplementary text for form fields |
| `FieldError` | `@heroui/react` | Validation error messages |
| `ErrorMessage` | `@heroui/react` | Low-level error message display |

### Date & Time

| Component | Import | Description |
|-----------|--------|-------------|
| `Calendar` | `@heroui/react` | Date picker with month grid and navigation |
| `RangeCalendar` | `@heroui/react` | Date range picker |
| `DateField` | `@heroui/react` | Date input field with validation |
| `DatePicker` | `@heroui/react` | DateField + Calendar composition |
| `DateRangePicker` | `@heroui/react` | DateField + RangeCalendar composition |
| `TimeField` | `@heroui/react` | Time input field with validation |

### Color

| Component | Import | Description |
|-----------|--------|-------------|
| `ColorPicker` | `@heroui/react` | Composable color picker |
| `ColorArea` | `@heroui/react` | 2D color gradient picker |
| `ColorSlider` | `@heroui/react` | Adjust individual color channel |
| `ColorField` | `@heroui/react` | Color input field |
| `ColorSwatch` | `@heroui/react` | Visual color preview |
| `ColorSwatchPicker` | `@heroui/react` | Predefined color palette |

### Data Display

| Component | Import | Description |
|-----------|--------|-------------|
| `Table` | `@heroui/react` | Structured data with sorting, selection, resizing |
| `Card` | `@heroui/react` | Flexible container for grouping content |
| `Avatar` | `@heroui/react` | User profile images with fallback |
| `Badge` | `@heroui/react` | Small indicator for counts, status dots |
| `Chip` | `@heroui/react` | Labels, statuses, categories |
| `Kbd` | `@heroui/react` | Keyboard shortcuts display |
| `ListBox` | `@heroui/react` | List of selectable options |
| `TagGroup` | `@heroui/react` | Focusable list of tags with removal |

### Layout & Structure

| Component | Import | Description |
|-----------|--------|-------------|
| `Separator` | `@heroui/react` | Visually divide content sections |
| `Surface` | `@heroui/react` | Container with surface-level styling |
| `Toolbar` | `@heroui/react` | Container for interactive controls |
| `ScrollShadow` | `@heroui/react` | Scroll overflow shadow indicators |

### Navigation

| Component | Import | Description |
|-----------|--------|-------------|
| `Tabs` | `@heroui/react` | Content sections with tab navigation |
| `Breadcrumbs` | `@heroui/react` | Navigation hierarchy |
| `Link` | `@heroui/react` | Styled anchor for navigation |
| `Pagination` | `@heroui/react` | Page navigation with prev/next |
| `Accordion` | `@heroui/react` | Collapsible content panels |
| `Disclosure` | `@heroui/react` | Collapsible section with header |
| `DisclosureGroup` | `@heroui/react` | Manages multiple Disclosure items |

### Overlays & Modals

| Component | Import | Description |
|-----------|--------|-------------|
| `Modal` | `@heroui/react` | Dialog overlay for focused interactions |
| `AlertDialog` | `@heroui/react` | Critical confirmation dialog |
| `Drawer` | `@heroui/react` | Slide-out panel |
| `Popover` | `@heroui/react` | Rich content in a portal |
| `Tooltip` | `@heroui/react` | Informative text on hover/focus |
| `Dropdown` | `@heroui/react` | List of actions/options |
| `Toast` | `@heroui/react` | Temporary notifications with auto-dismiss |

### Feedback & Loading

| Component | Import | Description |
|-----------|--------|-------------|
| `Alert` | `@heroui/react` | Important messages with status indicators |
| `Spinner` | `@heroui/react` | Loading indicator |
| `Skeleton` | `@heroui/react` | Loading placeholder |
| `ProgressBar` | `@heroui/react` | Determinate/indeterminate progress |
| `ProgressCircle` | `@heroui/react` | Circular progress indicator |
| `Meter` | `@heroui/react` | Quantity within a known range |

## Common Usage Patterns

### Button Variants

```tsx
import { Button } from "@heroui/react"

// Variants: solid, bordered, light, flat, faded, shadow, ghost
<Button color="primary" variant="solid">Primary</Button>
<Button color="danger" variant="flat">Delete</Button>
<Button color="default" variant="bordered">Cancel</Button>
<Button isLoading>Saving...</Button>
<Button isDisabled>Disabled</Button>
<Button startContent={<Icon />}>With Icon</Button>
```

### Modal Pattern

```tsx
import {
  Modal, ModalContent, ModalHeader, ModalBody, ModalFooter,
  Button, useDisclosure
} from "@heroui/react"

function MyModal() {
  const { isOpen, onOpen, onOpenChange } = useDisclosure()

  return (
    <>
      <Button onPress={onOpen}>Open</Button>
      <Modal isOpen={isOpen} onOpenChange={onOpenChange}>
        <ModalContent>
          {(onClose) => (
            <>
              <ModalHeader>Title</ModalHeader>
              <ModalBody>Content here</ModalBody>
              <ModalFooter>
                <Button color="danger" variant="light" onPress={onClose}>Close</Button>
                <Button color="primary" onPress={onClose}>Action</Button>
              </ModalFooter>
            </>
          )}
        </ModalContent>
      </Modal>
    </>
  )
}
```

### Form with TextField

```tsx
import { Form, TextField, Button } from "@heroui/react"

function MyForm() {
  return (
    <Form onSubmit={handleSubmit}>
      <TextField label="Name" name="name" isRequired />
      <TextField label="Email" name="email" type="email" isRequired />
      <Button type="submit" color="primary">Submit</Button>
    </Form>
  )
}
```

### Table Pattern

```tsx
import { Table, TableHeader, TableBody, TableColumn, TableRow, TableCell } from "@heroui/react"

function MyTable() {
  return (
    <Table aria-label="Users">
      <TableHeader>
        <TableColumn>Name</TableColumn>
        <TableColumn>Email</TableColumn>
        <TableColumn>Role</TableColumn>
      </TableHeader>
      <TableBody>
        <TableRow key="1">
          <TableCell>John</TableCell>
          <TableCell>john@example.com</TableCell>
          <TableCell>Admin</TableCell>
        </TableRow>
      </TableBody>
    </Table>
  )
}
```

### Card Pattern

```tsx
import { Card, CardHeader, CardBody, CardFooter, Button } from "@heroui/react"

function MyCard() {
  return (
    <Card>
      <CardHeader>Title</CardHeader>
      <CardBody>Content goes here</CardBody>
      <CardFooter>
        <Button color="primary">Action</Button>
      </CardFooter>
    </Card>
  )
}
```

### Select Pattern

```tsx
import { Select, SelectItem } from "@heroui/react"

function MySelect() {
  return (
    <Select label="Role" placeholder="Select a role">
      <SelectItem key="admin">Admin</SelectItem>
      <SelectItem key="user">User</SelectItem>
      <SelectItem key="viewer">Viewer</SelectItem>
    </Select>
  )
}
```

### Tabs Pattern

```tsx
import { Tabs, Tab } from "@heroui/react"

function MyTabs() {
  return (
    <Tabs aria-label="Options">
      <Tab key="overview" title="Overview">Overview content</Tab>
      <Tab key="settings" title="Settings">Settings content</Tab>
      <Tab key="billing" title="Billing">Billing content</Tab>
    </Tabs>
  )
}
```

### Toast Usage

```tsx
import { toast } from "@heroui/react"

// In your handler
toast.success("Item created successfully")
toast.error("Failed to save changes")
toast.info("Processing your request...")
```

### Dropdown Pattern

```tsx
import { Dropdown, DropdownTrigger, DropdownMenu, DropdownItem, Button } from "@heroui/react"

function MyDropdown() {
  return (
    <Dropdown>
      <DropdownTrigger>
        <Button variant="bordered">Actions</Button>
      </DropdownTrigger>
      <DropdownMenu aria-label="Actions">
        <DropdownItem key="edit">Edit</DropdownItem>
        <DropdownItem key="delete" className="text-danger" color="danger">Delete</DropdownItem>
      </DropdownMenu>
    </Dropdown>
  )
}
```

## Theming

HeroUI v3 uses CSS variables for theming. Customize via `globals.css`:

```css
@import "tailwindcss";
@import "@heroui/styles";

:root {
  --heroui-primary: oklch(0.6 0.25 260);
  --heroui-secondary: oklch(0.7 0.15 300);
}
```

## Key Principles

1. **All components from `@heroui/react`** — single import source
2. **Compound components** — Modal uses ModalContent/ModalHeader/ModalBody/ModalFooter
3. **Built on React Aria** — accessible by default
4. **Tailwind CSS v4** — style with utility classes
5. **`onPress` not `onClick`** — HeroUI uses React Aria's press events

## Full Documentation

- Components: https://www.heroui.com/docs/react/components
- Theming: https://www.heroui.com/docs/react/getting-started/theming
- Styling: https://www.heroui.com/docs/react/getting-started/styling
- Composition: https://www.heroui.com/docs/react/getting-started/composition
