package com.transportmanager.util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;

public final class ValidationUtil {

	private ValidationUtil() {
	}

	public static long parsePositiveLongOrDefault(String raw, long defaultValue) {
		if (raw == null || raw.isBlank()) {
			return defaultValue;
		}
		try {
			long value = Long.parseLong(raw.trim());
			return value > 0 ? value : defaultValue;
		} catch (NumberFormatException ex) {
			return defaultValue;
		}
	}

	public static int parseRangeIntOrDefault(String raw, int defaultValue, int min, int max) {
		if (raw == null || raw.isBlank()) {
			return defaultValue;
		}
		try {
			int value = Integer.parseInt(raw.trim());
			if (value < min || value > max) {
				return defaultValue;
			}
			return value;
		} catch (NumberFormatException ex) {
			return defaultValue;
		}
	}

	public static String trimToNull(String raw) {
		if (raw == null) {
			return null;
		}
		String value = raw.trim();
		return value.isEmpty() ? null : value;
	}

	public static String normalizeOverrideType(String raw) {
		if (raw == null || raw.isBlank()) {
			return null;
		}
		String value = raw.trim().toUpperCase();
		if ("BUS".equals(value) || "DRIVER".equals(value) || "BOTH".equals(value)) {
			return value;
		}
		return null;
	}

	public static LocalDate parseDateOrNull(String raw) {
		if (raw == null || raw.isBlank()) {
			return null;
		}
		try {
			return LocalDate.parse(raw.trim());
		} catch (DateTimeParseException ex) {
			return null;
		}
	}

	public static String sanitizePriority(String raw) {
		if (raw == null || raw.isBlank()) {
			return null;
		}
		String value = raw.trim().toUpperCase();
		if ("HIGH".equals(value) || "MEDIUM".equals(value) || "LOW".equals(value)) {
			return value;
		}
		return null;
	}
}

