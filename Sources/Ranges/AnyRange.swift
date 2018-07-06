/***************************************************************************************************
 AnyRange.swift
   © 2018 YOCKOW.
     Licensed under MIT License.
     See "LICENSE.txt" for more information.
 **************************************************************************************************/

/// # AnyRange
/// A container for ranges.
public struct AnyRange<Bound> where Bound: Comparable {
  internal enum _Range {
    case empty
    case unboundedRange
    case closedRange(ClosedRange<Bound>)
    case leftOpenRange(LeftOpenRange<Bound>)
    case openRange(OpenRange<Bound>)
    case range(Range<Bound>)
    case partialRangeFrom(PartialRangeFrom<Bound>)
    case partialRangeGreaterThan(PartialRangeGreaterThan<Bound>)
    case partialRangeThrough(PartialRangeThrough<Bound>)
    case partialRangeUpTo(PartialRangeUpTo<Bound>)
  }
  
  internal var _range: _Range
}

/// A container for countable ranges.
public typealias AnyCountableRange<Bound> =
  AnyRange<Bound> where Bound:Strideable, Bound.Stride:SignedInteger

extension AnyRange._Range {
  /// Initialize with an instance that conforms to `RangeExpression`.
  /// FIXME: Due to [SR-8291](https://bugs.swift.org/browse/SR-8192), `var isEmpty { get }` of
  ///        `OpenRange` might differ from the actual result.
  internal init<R>(_ range:R) where R:RangeExpression, R.Bound == Bound {
    switch range {
    case let closed as ClosedRange<Bound>:
      self = closed.isEmpty ? .empty : .closedRange(closed)
    case let leftOpen as LeftOpenRange<Bound>:
      self = leftOpen.isEmpty ? .empty : .leftOpenRange(leftOpen)
    case let open as OpenRange<Bound>:
        self = open.isEmpty ? .empty : .openRange(open)
    case let range as Range<Bound>:
      self = range.isEmpty ? .empty : .range(range)
    case let from as PartialRangeFrom<Bound>:
      self = .partialRangeFrom(from)
    case let greater as PartialRangeGreaterThan<Bound>:
      self = .partialRangeGreaterThan(greater)
    case let through as PartialRangeThrough<Bound>:
      self = .partialRangeThrough(through)
    case let upTo as PartialRangeUpTo<Bound>:
      self = .partialRangeUpTo(upTo)
    default:
      fatalError("Unimplemented range.")
    }
  }
}

extension AnyRange {
  /// Initialize with an instance that conforms to `RangeExpression`
  /// FIXME: Waiting for [SR-8291](https://bugs.swift.org/browse/SR-8192) to be resolved.
  public init<R>(_ range:R) where R:RangeExpression, R.Bound == Bound {
    self._range = _Range(range)
  }
  
  /// Initialize an instance as a unbounded range.
  public init(_:UnboundedRange) {
    self._range = .unboundedRange
  }
  /// Represents an unbounded range.
  public static var unboundedRange: AnyRange<Bound> { return AnyRange<Bound>(...) }
  
  private struct _Empty {}
  private init(_:_Empty) { self._range = .empty }
  /// Represents an empty range.
  public static var empty: AnyRange<Bound> { return AnyRange<Bound>(_Empty()) }
}

extension AnyRange {
  /// Returns whether the receiver is empty or not.
  /// Due to [SR-8291](https://bugs.swift.org/browse/SR-8192), `false` might be returned although
  /// the receiver is empty when a certain empty `OpenRange` has been passed to the initializer.
  /// That's why `static var empty: AnyRange<Bound>` should be used when you want an empty range.
  /// FIXME: Waiting for [SR-8291](https://bugs.swift.org/browse/SR-8192) to be resolved.
  public var isEmpty: Bool {
    if case .empty = self._range { return true }
    return false
  }
}


