create database library; 
use library;
-- Table: tbl_publisher
CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress TEXT,
    publisher_PublisherPhone VARCHAR(15)
);
select * from tbl_publisher;
select count(*) as total from tbl_publisher;
-- Table: tbl_book
CREATE TABLE tbl_book (
    book_BookID INT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
);
select * from tbl_book;
select count(*) as total from tbl_book;


CREATE TABLE tbl_book_authors (
    book_authors_AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    book_authors_BookID INT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID) REFERENCES tbl_book(book_BookID)
);
select * from tbl_book_authors;

-- Table: tbl_library_branch
CREATE TABLE tbl_library_branch (
    library_branch_BranchID INT PRIMARY KEY AUTO_INCREMENT,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress TEXT
);
select * from tbl_library_branch;

-- Table: tbl_book_copies
CREATE TABLE tbl_book_copies (
    book_copies_CopiesID INT PRIMARY KEY AUTO_INCREMENT,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_copies_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID)
);
select * from tbl_book_copies;
-- Table: tbl_borrower
CREATE TABLE tbl_borrower (
    borrower_CardNo INT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress TEXT,
    borrower_BorrowerPhone VARCHAR(15)
);
select * from tbl_borrower;
-- Table: tbl_book_loans
CREATE TABLE tbl_book_loans (
    book_loans_LoansID INT PRIMARY KEY AUTO_INCREMENT,
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut DATE,
    book_loans_DueDate DATE,
    FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID),
    FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID),
    FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(borrower_CardNo)
);
select * from tbl_book_loans;

-- 1) How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?--
select sum(book_copies_No_Of_Copies) as total,library_branch_BranchName,book_Title  from tbl_book b inner join
 tbl_book_copies t on  b.book_BookID = t.book_copies_BookID
inner join tbl_library_branch lb on t.book_copies_BranchID = lb.library_branch_BranchID 
group by library_branch_BranchName,book_Title
having book_Title="The Lost Tribe" and library_branch_BranchName='Sharpstown';

-- 2) How many copies of the book titled "The Lost Tribe" are owned by each library branch?--
select sum(book_copies_No_Of_Copies) as total,library_branch_BranchName,book_Title  from tbl_book b inner join tbl_book_copies t 
on  b.book_BookID = t.book_copies_BookID
inner join tbl_library_branch lb on t.book_copies_BranchID = lb.library_branch_BranchID 
where book_Title="The Lost Tribe" 
group by library_branch_BranchName;

-- 3)Retrieve the names of all borrowers who do not have any books checked out.--
select borrower_BorrowerName from tbl_borrower t
left join tbl_book_loans tb on t.borrower_CardNo =  tb.book_loans_CardNo
where tb.book_loans_CardNo is null;

/* 4)For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, 
the borrower's name, and the borrower's address. */
select book_Title,borrower_BorrowerName,book_loans_DueDate from tbl_book b join tbl_book_loans t on b.book_BookID = t.book_loans_BookID
join tbl_library_branch lb on t.book_loans_BranchID =lb.library_branch_BranchID join tbl_borrower br on 
br.borrower_CardNo = t.book_loans_CardNo where library_branch_BranchName ='Sharpstown' and book_loans_DueDate = '2018-03-02'  ;

-- 5) For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select library_branch_BranchName ,count(book_loans_BookID) as total from tbl_library_branch lb join tbl_book_loans bl on 
lb.library_branch_BranchID =  bl.book_loans_BranchID
group by library_branch_BranchName;

-- 6)Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
select borrower_BorrowerName ,borrower_BorrowerAddress ,count(book_loans_BookID) as total from tbl_borrower as tb join tbl_book_loans tl on
tb.borrower_CardNo = tl.book_loans_CardNo
group by  borrower_BorrowerName ,borrower_BorrowerAddress
having total >5;

-- 7) For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select book_authors_AuthorName,book_Title,library_branch_BranchName,sum(book_copies_No_Of_Copies) as total_copies from tbl_book_authors ta
 join tbl_book tb on ta.book_authors_BookID = tb.book_BookID join tbl_book_copies tc on tb.book_BookID = tc.book_copies_BookID join 
 tbl_library_branch tl on tc.book_copies_BranchID = tl.library_branch_BranchID
where book_authors_AuthorName="Stephen King" and library_branch_BranchName = 'Central'
group by book_authors_AuthorName,book_Title,library_branch_BranchName ;


-- 8) How many copies of each book are available in each library branch ?
SELECT 
    b.book_Title,
    lb.library_branch_BranchName,
    SUM(bc.book_copies_No_Of_Copies) AS total_copies
FROM tbl_book b
JOIN tbl_book_copies bc ON b.book_BookID = bc.book_copies_BookID
JOIN tbl_library_branch lb ON bc.book_copies_BranchID = lb.library_branch_BranchID
GROUP BY b.book_Title, lb.library_branch_BranchName;


-- 9) Write a query to display the titles of the most borrowed books along wit the number of times each book has been borrowed?
SELECT 
    b.book_Title,
    COUNT(bl.book_loans_LoansID) AS times_borrowed
FROM tbl_book b
JOIN tbl_book_loans bl ON b.book_BookID = bl.book_loans_BookID
GROUP BY b.book_Title
ORDER BY times_borrowed DESC
LIMIT 5;


