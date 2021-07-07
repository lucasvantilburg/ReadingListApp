//
//  ReadingListModel.swift
//  Reading List App
//
//  Created by CodeWithChris on 2021-04-23.
//

import Foundation
import Firebase

class ReadingListModel: ObservableObject {
    // Variables to temporarily store the genres and books information from the database
    @Published var genres : [String] = []
    // Dictionary to match Genres to an array of Books
    @Published var books : [String: [Book]] = [:]
    
    @Published var statuses : [String] = ["Plan to read", "Reading", "On hold", "Completed"]

    init() {
        getGenres()
    }
    
    // TODO: Complete all Firestore functions
    /// Adds a document with auto-genrated ID to the books collection in the Firestore database
    ///
    /// Parameters:
    ///     - book: The book to add to the database
    func addBook(book: Book) {
        let db = Firestore.firestore()
        
        let books = db.collection("books")
        
        
        let book = books.addDocument(data: ["title" : book.title, "author": book.author, "genre": book.genre, "status": book.status, "pages": book.pages, "rating": book.rating])
        
        //add ID as field
        book.updateData(["id" : book.documentID])
    }
    
    /// Deletes a specific book document in the books collection in the Firestore database
    ///
    /// Parameters:
    ///     - book: The book to delete in  the database
    func deleteBook(book: Book) {
        let db = Firestore.firestore()
        
        let booksDB = db.collection("books")
        
        let bookDB = booksDB.document(book.id)
        
        bookDB.delete()
        
    }
    
    /// Updates a book document's genre, status, and rating fields, in the books collection in the Firestore database
    ///
    /// Parameters:
    ///     - book: The book to update in the database
    func updateBookData(book: Book) {
        let db = Firestore.firestore()
        
        let booksDB = db.collection("books")
        
        let bookDB = booksDB.document(book.id)
        
        bookDB.updateData(["genre" : book.genre, "status": book.status, "rating": book.rating])
    }
    
    /// Queries the books collection in the Firestore database and finds all book documents with the matching "genre" field value. Updates the "books" class field with the queried book documents' data
    ///
    /// Parameters:
    ///     - genre: The genre to match when querying the book documents
    func getBooksByGenre(genre: String) {
        let db = Firestore.firestore()
        
        let booksDB = db.collection("books")
        
        let query = booksDB.whereField("genre", isEqualTo: genre)
        
        self.books[genre] = []
        
        query.getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else if let querySnapshot = querySnapshot {
                
                for doc in querySnapshot.documents {
                    let data = doc.data()
                    
                    //convert data to Book
                    let book = Book(id: data["id"] as! String, title: data["title"] as! String, author: data["author"] as! String, genre: data["genre"] as! String, status: data["status"] as! String, pages: data["pages"] as! Int, rating: data["rating"] as! Int)
                    
                    //add book to dictionary
                    self.books[genre]!.append(book)
                }
            }
            
        }
    }

    /// Adds a genre document with the genre as the document ID to the genres collection
    ///
    /// Parameters:
    ///     - genre: The name of the genre to add to the Firestore database
    func addGenre(genre: String) {
        let db = Firestore.firestore()
        
        let genres = db.collection("genres")
        
        genres.document(genre).setData(["genre" : genre])
    }
    
    /// Gets all genre documents in the genres collection in the Firestore database and updates the "genres" class field with the genre document ID names.
    ///
    /// Parameters:
    ///     - genre: The genre to match when querying the book documents
    func getGenres() {
        let db = Firestore.firestore()
        
        let genres = db.collection("genres")
        
        self.genres = []
        
        genres.getDocuments { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else if let querySnapshot = querySnapshot {
                
                for doc in querySnapshot.documents {
                    self.genres.append(doc.documentID)
                }
            }
        }
    }
}
