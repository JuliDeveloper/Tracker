import UIKit

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

struct GeometricParams1 {
    let cellCount: Int
    let leftInset: CGFloat
    let smallLeftInset: CGFloat?
    let rightInset: CGFloat
    let smallRightInset: CGFloat?
    let cellSpacing: CGFloat
    let smallCellSpacing: CGFloat?
    let lineCellSpacing: CGFloat?
    let smallLineCellSpacing: CGFloat?
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, smallLeftInset: CGFloat?, rightInset: CGFloat, smallRightInset: CGFloat?, cellSpacing: CGFloat, smallCellSpacing: CGFloat?, lineCellSpacing: CGFloat?, smallLineCellSpacing: CGFloat?) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.smallLeftInset = smallLeftInset
        self.rightInset = rightInset
        self.smallRightInset = smallLeftInset
        self.cellSpacing = cellSpacing
        self.smallCellSpacing = smallCellSpacing
        self.lineCellSpacing = lineCellSpacing
        self.smallLineCellSpacing = smallCellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
