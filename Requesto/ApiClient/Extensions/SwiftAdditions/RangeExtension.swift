extension Range {
    func intersects(_ other: Range) -> Bool {
        return self.contains(other.lowerBound) || other.contains(self.lowerBound)
    }
}
