---
name: spin
description: Spin a topic that came up in this conversation off into its own herdr space in another repo, with a fresh Claude session there that starts from a brief of the relevant context. Use when the user says "/spin <repo> <topic>", "spin this off", "spin up a space in <repo> to discuss X", "open a space in <repo> for this", or similar.
argument-hint: <repo or folder> <topic>
---

# spin

Opens a herdr space in another checkout: a "claude" tab that starts on a brief you write, and a
"shell" tab. The space you are in stays selected, so the user carries on here.

1. **Target and topic.** The target is a repo name (`aule`, `services/aule`) or a folder
   (`~/x`). The topic is what to discuss there. Ask only if the request and the conversation
   leave either unclear.

2. **Write the brief** to a file in your scratchpad. The new session has seen nothing of this
   conversation, so the brief must stand on its own:
   - **Origin:** one line on what this conversation is about (repo, branch, issue) and how the
     topic came up.
   - **Topic:** what to work out, as a question or goal.
   - **Context:** the facts, decisions and constraints from this conversation that bear on the
     topic, with concrete names (files, functions, components, datapoints, issue numbers). Not a
     summary of the whole conversation.
   - **Open questions:** what is still undecided.
   - End with: discuss and propose first; change no code until the user says so.

   Keep it as short as it can be while complete, usually 10 to 30 lines.

3. **Open the space:**

   ```sh
   node ~/.config/herdr-app/tools/spin.js <target> --name "<name>" < <brief file>
   ```

   - `<name>`: 2 to 4 lowercase words naming the topic, not the repo.
   - Add `--focus` only when the user asks to go there.
   - When several repositories match, it lists their labels: ask which, then rerun with one.

4. **Reply** in one line with the space name and folder. Don't repeat the brief, and don't carry
   on with the spun-off topic here.

The space opens on the repo's main checkout, which is right for discussion. Work that comes out
of it goes through an issue and its own worktree.
