import UIKit

protocol NotesListVCDelegate:class {
    func noteEditingVCDidClose(sender:NotesListVC)
    func NoteEditingVCDidChange(sender:NotesListVC, note:NoteModel)
}

class NotesListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    public weak var actionDelegate:NotesListVCDelegate?
    public var book:BookMVVM?
    public var notes:[NoteModel] = []

    private var deleteBookNoteRequest: DeleteBookNoteRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshHandler), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.contentInset = UIEdgeInsets(top: 100, left: tableView.contentInset.left, bottom: tableView.contentInset.bottom, right: tableView.contentInset.right)
        
        reload()
    }
    
    @objc func onRefreshHandler(refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        reload()
    }

    @IBAction func backHandler(_ sender: Any) {
        self.actionDelegate?.noteEditingVCDidClose(sender: self)
    }
    
    @IBAction func addNoteTapHandler(_ sender: Any) {
        if let noteEditingVC = Books.VC(.NoteEditing) as? NoteEditingVC {
            noteEditingVC.title = NSLocalizedString("Add note", comment: "")
            noteEditingVC.editingMode = .create(String(book!.bookModel.id))
            noteEditingVC.actionDelegate = self
            noteEditingVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(noteEditingVC, animated: true)
        }
    }
    
    private func reload(){
        spinner.startAnimating()
        book?.getListBookNotes(completion: {[weak self] (notes:[NoteModel]?, message:String?) in
            guard let self = self else {return}
            self.spinner.stopAnimating()
            
            if let notes = notes {
                self.notes = notes
                self.tableView.reloadData()
            }
            else{
                self.showAlert(withMessage: message ?? kDefaultErrorMessage)
            }
        })
    }
    
    deinit {
        self.deleteBookNoteRequest?.cancel()
    }
}

extension NotesListVC: NoteEditingVCDelegate {
    func noteEditingVCDidClose(sender: NoteEditingVC) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func noteEditingVCDidDone(sender: NoteEditingVC, note: NoteModel) {
        self.reload()
        self.navigationController?.popViewController(animated: true)
        
        switch sender.editingMode {
        case .create:
            fatalError("Wrong case")
        case .edit(let noteModel, _):
            self.actionDelegate?.NoteEditingVCDidChange(sender: self, note: noteModel)
        case .none:
            fatalError("Wrong case")
        }
    }
}

extension NotesListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let noteEditingVC = Books.VC(.NoteEditing) as? NoteEditingVC {
            noteEditingVC.title = NSLocalizedString("Edit note", comment: "")
            noteEditingVC.editingMode = .edit(notes[indexPath.row])
            noteEditingVC.actionDelegate = self
            noteEditingVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(noteEditingVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            spinner.startAnimating()
            let note = notes[indexPath.row]
            deleteBookNoteRequest = DeleteBookNoteRequest()
            deleteBookNoteRequest?.run(noteId: String(note.id), completion: {[weak self] (success:Bool, message:String?) in
                guard let self = self else {return}
                self.deleteBookNoteRequest = nil
                self.spinner.stopAnimating()
                
                if success {
                    self.notes.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                else{
                    self.showAlert(withMessage: message ?? kDefaultErrorMessage)
                }
            })
        }
    }
}

extension NotesListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(NoteTVCell.self)
        let note = notes[indexPath.row]
        cell.dateLabel.text = note.updatedAt.UTCToLocal()
        cell.quoteLabel.text = note.text
        cell.quoteView.isHidden = note.text?.isEmpty ?? true
        cell.noteLabel?.text = note.comment
        return cell
    }
    
}
