import UIKit

open class DayViewController: UIViewController, EventDataSource, DayViewDelegate {
    public lazy var dayView: DayView = DayView()
    private var emptyView: UIView?
    public var dataSource: EventDataSource? {
        get {
            dayView.dataSource
        }
        set(value) {
            dayView.dataSource = value
        }
    }

    public var delegate: DayViewDelegate? {
        get {
            dayView.delegate
        }
        set(value) {
            dayView.delegate = value
        }
    }

    public var calendar = Calendar.autoupdatingCurrent {
        didSet {
            dayView.calendar = calendar
        }
    }

    public var eventEditingSnappingBehavior: EventEditingSnappingBehavior {
        get {
            dayView.eventEditingSnappingBehavior
        }
        set {
            dayView.eventEditingSnappingBehavior = newValue
        }
    }

    open override func loadView() {
        view = dayView
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.tintColor = SystemColors.systemRed
        dataSource = self
        delegate = self
        dayView.reloadData()

        let sizeClass = traitCollection.horizontalSizeClass
        configureDayViewLayoutForHorizontalSizeClass(sizeClass)
        
        addEmptyViewIfEventIsEmpty(for: dayView.state?.selectedDate ?? Date())
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dayView.scrollToFirstEventIfNeeded()
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        configureDayViewLayoutForHorizontalSizeClass(newCollection.horizontalSizeClass)
    }

    open func configureDayViewLayoutForHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        dayView.transitionToHorizontalSizeClass(sizeClass)
    }

    // MARK: - CalendarKit API

    open func move(to date: Date) {
        dayView.move(to: date)
    }

    open func reloadData() {
        dayView.reloadData()
    }

    open func updateStyle(_ newStyle: CalendarStyle) {
        dayView.updateStyle(newStyle)
    }

    open func eventsForDate(_ date: Date) -> [EventDescriptor] {
        [Event]()
    }

    // MARK: - DayViewDelegate

    open func dayViewDidSelectEventView(_ eventView: EventView) {}
    open func dayViewDidLongPressEventView(_ eventView: EventView) {}

    open func dayView(dayView: DayView, didTapTimelineAt date: Date) {}
    open func dayViewDidBeginDragging(dayView: DayView) {}
    open func dayViewDidTransitionCancel(dayView: DayView) {}

    open func dayView(dayView: DayView, willMoveTo date: Date) { }
    open func dayView(dayView: DayView, didMoveTo date: Date) {
        addEmptyViewIfEventIsEmpty(for: date)
    }

    open func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {}
    open func dayView(dayView: DayView, didUpdate event: EventDescriptor) {}

    // MARK: - Editing

    open func create(event: EventDescriptor, animated: Bool = false) {
        dayView.create(event: event, animated: animated)
    }

    open func beginEditing(event: EventDescriptor, animated: Bool = false) {
        dayView.beginEditing(event: event, animated: animated)
    }

    open func endEventEditing() {
        dayView.endEventEditing()
    }
    
    open func getEmptyView(forDate : Date) -> UIView? { return nil }
    
    open func dayView(dayView: DayView, didScrolled : UIScrollView) {
        
    }
}

public extension DayViewController {
    func addEmptyViewIfEventIsEmpty(for date: Date) {
        emptyView?.removeFromSuperview()
        
        guard let dataSource,
        dataSource.eventsForDate(date).isEmpty,
        let emptyView = getEmptyView(forDate: date) else { return }
        
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        dayView.addSubview(emptyView)
        NSLayoutConstraint.activate(
            [
                emptyView.leadingAnchor.constraint(equalTo: dayView.leadingAnchor),
                emptyView.trailingAnchor.constraint(equalTo: dayView.trailingAnchor),
                emptyView.topAnchor.constraint(equalTo: dayView.topAnchor),
                emptyView.bottomAnchor.constraint(equalTo: dayView.bottomAnchor),
            ]
        )
        self.emptyView = emptyView
    }
}
