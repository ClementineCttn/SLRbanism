import fitz
import os
import sys

# Adapted from https://towardsdatascience.com/read-a-multi-column-pdf-using-pymupdf-in-python-4b48972f82dc
        
def convert_pdf(file_list):
    '''
    Function converts the pdf files to text. It allow unusual pdf layout (multiple columns)

    Parameters
    -----------
    file_list : list 
        The list of files to be converted
    
    Returns
    ------------
    text_list: list 
        The list  body of text of each of the file as character strings 

    '''
    text_list = []
    for i, file in enumerate(file_list): 
        l = []
        assert os.path.isfile(file), f"No such file: {file}"
        with fitz.open(file) as doc:
            for page in doc:
                text = page.get_text(sort=True)
                l.append(text)
        
        l = ' '.join(l)
        text_list.append(l)
    
    return(text_list)






