/**
 * WezTerm integration plugin for opencode
 *
 * Provides:
 * - TTS notification when opencode finishes (session.idle)
 * - TTS notification when opencode needs input (permission.asked, question.asked)
 * - WezTerm amber tab indicator when opencode is waiting (session.idle)
 * - WezTerm task number display when workflow commands are submitted (chat.message)
 * - WezTerm status clear when user responds (chat.message)
 *
 * Calls the existing shell scripts in .opencode/hooks/ to reuse all
 * the WezTerm OSC 1337 logic, piper TTS logic, and cooldown handling.
 */
export const WeztermHooksPlugin = async ({ $, directory }) => {
  const hookDir = `${directory}/.opencode/hooks`;

  return {
    // Generic event handler for session lifecycle and permission events
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        // Opencode finished responding - TTS + wezterm amber tab
        await $`bash ${hookDir}/tts-notify.sh`
          .cwd(directory).quiet().nothrow();
        await $`bash ${hookDir}/wezterm-notify.sh`
          .cwd(directory).quiet().nothrow();
      } else if (
        event.type === "permission.asked" ||
        event.type === "question.asked"
      ) {
        // Opencode needs input or is asking a question - TTS only
        await $`bash ${hookDir}/tts-notify.sh`
          .cwd(directory).quiet().nothrow();
      }
    },

    // Called when a user message is submitted to the model
    "chat.message": async (input, output) => {
      // Extract the text the user typed
      const textPart = output.parts.find((p) => p.type === "text");
      const prompt = textPart?.text ?? "";

      // Pass prompt as JSON on stdin (wezterm-task-number.sh reads .prompt from stdin JSON)
      const hookInput = JSON.stringify({ prompt });
      await $`echo ${hookInput} | bash ${hookDir}/wezterm-task-number.sh`
        .cwd(directory).quiet().nothrow();

      // Clear the wezterm amber status since user is now responding
      await $`bash ${hookDir}/wezterm-clear-status.sh`
        .cwd(directory).quiet().nothrow();
    },
  };
};
