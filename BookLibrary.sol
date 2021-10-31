pragma solidity ^0.8.0;
pragma abicoder v2;
import "./2_Owner";

contract BookLibrary is Owner {
    struct Book {
        uint256 id;
        string name;
    }

    Book[] books;

    mapping(uint256 => address) bookToOwner;
    mapping(uint256 => address[]) public bookToPreviousOwners;

    //make this only avaible for the owner
    function addBook(string memory _name, uint256 quantity) public isOwner {
        require(bytes(_name).length > 0);
        for (uint256 i = 0; i < quantity; i++) {
            books.push(Book(books.length, _name));
        }
    }

    function _isBookAvailable(uint256 _id) internal view returns (bool) {
        if (bookToOwner[_id] == address(0)) {
            return true;
        }
        return false;
    }

    function getAvailableBooks() public view returns (Book[] memory) {
        uint256 freeBooksCount = 0;
        for (uint256 i = 0; i < books.length; i++) {
            if (_isBookAvailable(books[i].id) == true) {
                freeBooksCount++;
            }
        }

        Book[] memory booksResult = new Book[](freeBooksCount);

        for (uint256 i = 0; i < books.length; i++) {
            if (bookToOwner[books[i].id] == address(0)) {
                booksResult[i] = Book(books[i].id, books[i].name);
            }
        }

        return booksResult;
        //returns a set of Books {id,name}
    }

    function _hasBorrowedPreviously(uint256 _id) private view returns (bool) {
        for (uint256 i = 0; i < bookToPreviousOwners[_id].length; i++) {
            if (bookToPreviousOwners[_id][i] == msg.sender) {
                return true;
            }
        }

        return false;
    }

    function borrowBook(uint256 _id) public {
        require(_isBookAvailable(_id));
        bookToOwner[_id] = msg.sender;
        if (_hasBorrowedPreviously(_id)) {
            bookToPreviousOwners[_id].push(msg.sender);
        }
    }

    function _isBookOwner(uint256 _id) private view returns (bool) {
        if (bookToOwner[_id] == msg.sender) {
            return true;
        }
        return false;
    }

    function returnBook(uint256 _id) public {
        require(_isBookAvailable(_id) == false);
        require(_isBookOwner(_id));

        delete bookToOwner[_id];
    }
}
