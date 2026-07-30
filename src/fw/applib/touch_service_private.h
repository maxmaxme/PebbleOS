/* SPDX-FileCopyrightText: 2026 Core Devices LLC */
/* SPDX-License-Identifier: Apache-2.0 */

#pragma once

#include "event_service_client.h"
#include "touch_service.h"

#include <stdbool.h>

//! Where a finger currently is, tracked between events so a subscriber can turn
//! absolute positions into deltas. Lives in per-task state because the app and
//! the kernel can both have a drag in flight — a modal window over a running
//! app, say — and file-static tracking in applib would be shared between them.
typedef struct TouchDragState {
  const void *owner;
  int16_t last_y;
  bool active;
} TouchDragState;

//! Per-task state for the applib touch service. Must live in task-accessible
//! memory (app/kernel state) so syscalls that validate buffers see it
//! as userspace-local.
typedef struct TouchServiceState {
  TouchServiceHandler raw_handler;
  void *raw_context;
  EventServiceInfo raw_event_info;
  bool raw_subscribed;
  TouchDragState drag;
} TouchServiceState;

//! Initialize the state struct to a quiescent state.
void touch_service_state_init(TouchServiceState *state);

//! @return the calling task's drag tracking slot, or NULL if this task may not
//! use touch (a watchface, a worker, or a platform without a touchscreen).
TouchDragState *touch_service_get_drag_state(void);
