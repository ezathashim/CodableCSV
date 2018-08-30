import Foundation

/// Instances of this class are capable of encoding CSV files as described by the `Codable` protocol.
open class CSVEncoder {
    /// Wrap all configurations in a single easy to use structure.
    private var configuration: CSV.Configuration
    
    /// The field and row delimiters.
    ///
    /// Defaults to "comma" (i.e. `,`) for field delimiter and "line feed" (i.e. `\n`) for a row delimiter.
    public var delimiters: CSV.Delimiter.Pair {
        get { return self.configuration.delimiters }
        set { self.configuration.delimiters = newValue }
    }
    
    /// Whether the CSV data contains headers at the beginning of the file.
    ///
    /// Defaults to "no header".
    public var headerStrategy: CSV.Strategy.Header {
        get { return self.configuration.headerStrategy }
        set { self.configuration.headerStrategy = newValue }
    }
    
    /// The strategy to use in decoding dates.
    ///
    /// Default to however the `Date` initializer works.
    public var dateStrategy: CSV.Strategy.Date {
        get { return self.configuration.dateStrategy }
        set { self.configuration.dateStrategy = newValue }
    }
    
    /// The strategy to use in decoding binary data.
    ///
    /// Defaults to base 64 decoding.
    public var dataStrategy: CSV.Strategy.Data {
        get { return self.configuration.dataStrategy }
        set { self.configuration.dataStrategy = newValue }
    }
    
    /// The strategy to use in decoding non-conforming numbers.
    ///
    /// Defaults to throw when confronting non-conforming numbers.
    public var nonConfirmingFloatStrategy: CSV.Strategy.NonConformingFloat {
        get { return self.configuration.floatStrategy }
        set { self.configuration.floatStrategy = newValue }
    }
    
    /// A dictionary you use to customize the decoding process by providing contextual information.
    open var userInfo: [CodingUserInfoKey:Any] = [:]
    
    /// Designated initializer specifying default configuration values for the parser.
    /// - parameter configuration: Optional configuration values for the decoding process.
    public init(configuration: CSV.Configuration = .init()) {
        self.configuration = configuration
    }
    
    /// Returns a data blob with the provided value encoded as a CSV.
    ///
    /// As optional parameter, the initial data capacity can be set. This doesn’t necessarily allocate the requested memory right away. The function allocates additional memory as needed, so capacity simply establishes the initial capacity. When it does allocate the initial memory, though, it allocates the specified amount.
    ///
    /// If the capacity specified in capacity is greater than four memory pages in size, this may round the amount of requested memory up to the nearest full page.
    /// - parameter value: The value to encode as CSV.
    /// - parameter capacity: The size of the data.
    open func encode<T:Encodable>(_ value: T, capacity: Int = 500) throws -> Data {
        let encoder = try ShadowEncoder(output: .data(capacity: capacity), configuration: self.configuration, userInfo: self.userInfo)
        try value.encode(to: encoder)
        return (encoder.output as! ShadowEncoder.Output.DataBlob).data
    }
    
    /// Writes the given value in the given file URL as a CSV.
    /// - parameter value: The value to encode as CSV.
    /// - parameter url: File URL where the data will be writen (replacing any content in case there were some).
    open func encode<T:Encodable>(_ value: T, url: URL) throws {
        let encoder = try ShadowEncoder(output: .file(url: url), configuration: self.configuration, userInfo: self.userInfo)
        try value.encode(to: encoder)
        try (encoder.output as! ShadowEncoder.Output.File).close()
    }
}
