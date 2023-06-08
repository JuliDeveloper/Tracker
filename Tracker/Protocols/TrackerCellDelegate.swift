import UIKit

protocol TrackerCellDelegate: AnyObject {
    func contextMenuNeeded(forCell cell: TrackerCell) -> UIContextMenuConfiguration?
}
