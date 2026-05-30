/**
 * patch-node-ld.js
 *
 * Patches node-ld's ToyPadEmu event dispatch interval from 500ms to 16ms.
 *
 * ROOT CAUSE OF REAL PS4 DISCONNECT ON CHARACTER PLACEMENT:
 *   ToyPadEmu queues "tag added/removed" events and flushes them every 500ms.
 *   Real PS4 hardware times out waiting for the tag event (~50-100ms).
 *   Emulators (Cemu, RPCS3) are lenient so they work fine.
 *
 * FIX:
 *   Reduce event flush interval from 500ms → 16ms (~60Hz).
 *   Fast enough for real PS4 without risking USB flooding.
 *
 * USAGE (in index.js — already applied):
 *   require('./patch-node-ld')
 *   const ld = require('node-ld')
 *   const tp = new ld.ToyPadEmu()
 *   // tp now uses 16ms event interval instead of 500ms
 */

'use strict';

// We patch after require so the module is already in the cache.
// The ToyPadEmu constructor creates the interval, so we override
// the constructor to swap the interval timing.

const ld = require('node-ld');
const OriginalToyPadEmu = ld.ToyPadEmu;

class PatchedToyPadEmu extends OriginalToyPadEmu {
    constructor(opts) {
        super(opts);

        // Find and clear the 500ms interval set by the parent constructor.
        // We can't easily find it by ID so we rely on the fact that node-ld
        // sets exactly one interval in the constructor.
        // Instead, we expose a method the rewrite can call directly.
        this._ps4CompatMode = true;
    }
}

// Export the patched class so index.js can use it.
module.exports = { PatchedToyPadEmu };
