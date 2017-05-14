pragma solidity ^0.4.2;
contract Bookchain {

    mapping(uint => Book) books;
    uint nextId = 0;

    struct Book {
        uint id;
        address origin;
        address user;
        uint price;
        uint donated;
        bytes[] comments;
        string isbn;
    }

    event bookAdded(uint id);
    event bookFreed(uint id);

    function addBook(uint _price, string _isbn) {
        uint _id = nextId++;
        var book = books[_id];
        book.origin = msg.sender;
        book.user = msg.sender;
        book.price = _price;
        book.isbn = _isbn;
        bookAdded(_id);
    }

    function free_book(uint _id) {
        var book = books[_id];
        if (msg.sender != book.origin) throw;
        book.user = 0x0;
        bookFreed(_id);
    }

    function borrow_book(uint _id) {
        var book = books[_id];
        if (book.user != 0x0) throw;
        book.user = msg.sender;
    }

    function comment(uint _id, bytes _ipfs_hash) {
        var book = books[_id];
        book.comments.push(_ipfs_hash);
    }

    function donate(uint _id) {

        // Get book
        Book book = books[_id];

        // If donation limit reached -> throw
        if (book.donated >= book.price) throw;

        // Calculate remaining donation space
        uint remaining = book.price - book.donated;

        // Default: donation == amount sent, diff == 0
        uint donation = msg.value;
        uint diff = 0;

        // Cap donation to remaining space
        if (donation > remaining) {
            donation = remaining;
            diff = msg.value - donation;
        }

        // Send donation to owner
        if (!book.origin.send(donation)) throw;

        // If diff between amount sent and donation, refund sender
        if (diff > 0) {
            if (!msg.sender.send(diff)) throw;
        }

    }

}
