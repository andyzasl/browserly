import AppKit

enum SourceAppResolver {
    /// The foreground app may already be Browserly when a URL arrives.
    /// Use the event's sender instead; unavailable metadata means an unknown source.
    static func bundleIdentifier(
        from event: NSAppleEventDescriptor?,
        lookup: (pid_t) -> String? = { NSRunningApplication(processIdentifier: $0)?.bundleIdentifier }
    ) -> String? {
        guard let sender = event?.attributeDescriptor(forKeyword: AEKeyword(keySenderPIDAttr)),
              sender.descriptorType == DescType(typeSInt32),
              sender.data.count == MemoryLayout<Int32>.size,
              sender.int32Value > 0 else {
            return nil
        }

        return lookup(pid_t(sender.int32Value))
    }
}
