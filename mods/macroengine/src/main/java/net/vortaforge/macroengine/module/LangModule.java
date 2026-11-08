package net.vortaforge.macroengine.module;

import net.vortaforge.macroengine.lang.Lang;

/**
 * {@code vf_log} - log a localised message.
 *
 * <p>This module exists so a caller can log a message that is translated: the
 * first argument is a translation key, the rest are positional placeholders,
 * resolved against the server's configured language with English as the
 * guaranteed fallback.
 *
 * <pre>
 *   /macroengine module vf_log macroengine.log.report_header 3 120
 * </pre>
 *
 * <p>Callers were {@code /function macroengine:module/vf_log {key:...}} before the
 * bundled datapack was removed. The Brigadier form above is the only one now.
 */
public final class LangModule implements MacroModule {

    @Override
    public String id() {
        return "vf_log";
    }

    @Override
    public String description() {
        return "Log a localised message via a translation key";
    }

    @Override
    public String run(Context ctx) throws ModuleException {
        String[] args = ctx.args();
        if (args.length == 0 || args[0].isBlank()) {
            throw new ModuleException("vf_log needs a translation key as its first argument");
        }
        String key = args[0].trim();
        if (!Lang.has(key)) {
            // Report the miss rather than logging a raw key at a player. A missing
            // key in a released pack is a defect worth seeing in the log.
            throw new ModuleException("vf_log: no translation for key '" + key + "'");
        }
        String[] placeholders = new String[Math.max(0, args.length - 1)];
        System.arraycopy(args, 1, placeholders, 0, placeholders.length);

        String rendered = Lang.format(key, (Object[]) placeholders);
        ctx.log(rendered);
        return rendered;
    }
}
