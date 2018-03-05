is how I got around needing sudo privallages, add a path to look for imports 
import sys
#sys.path.insert(0, '/Users/alexandrasalem/Documents/gensim-3.3.0')
import gensim
import csv
from numpy.linalg import norm
from numpy import zeros
from numpy import dot

EMBEDDING_DIM = 300
MODEL_PATH = '/Users/joel/devel/word2vec_model/GoogleNews-vectors-negative300.bin' 


def normalize(vector):
    norm_of_vec = norm(vector)
    if norm_of_vec == 0:
        return vector
    return vector/norm_of_vec    


def doc_to_vector(document_as_list, 
                  model,
                  do_normalize=True,
                  embedding_dimension=EMBEDDING_DIM):
    """
    transforms a document into a vector representing the sum of its 
        word embeddings.

        * document_as_list: ['this', 'is', 'a', 'document']
        * model: gensim word2vec model object.
        * do_normalize: normalize the resulting vectors to unit length?

    returns:
        * doc: the document as an embedding_dimension-ary vector
        * word_errors: a set of words that fail lookup in the model.
    """

    #TODO: can't you query the model object for its dimension?

    word_errors = set([]) 

    doc = zeros((embedding_dimension,))
    for word in document_as_list:
        try:
            word_vector = model[word]
            doc += word_vector 
        except KeyError:
            word_errors.add(word)

    if do_normalize:
        doc = normalize(doc)

    return (doc, word_errors)


def cos_sim(vector1, vector2):
    """
    calculates cos similarity between vector1, vector2.

    assumes these are already normalized.
    """
    #TODO: briefly consider whether we can count on the gold standard being unit length. 
    sim = dot(vector1, vector2)
    return sim

def calculate_all_sims(gold_standard_doc_vector,
                       list_of_doc_as_vectors,
                       sim_function=cos_sim,
                       outfile_path='similarities.csv'):
    """
    calculates and writes to a file the similarity between all vectores in 
        * list_of_doc_as_vectors
    and 
        * gold_standard_doc_vector
    """

    #TODO: Do we need to track some information about which file we're running?
    with open(outfile_path, 'w') as csvfile:
        writer = csv.writer(csvfile)
        for doc_as_vector in list_of_doc_as_vectors:
            sim = sim_function(doc_as_vector, gold_standard_doc_vector)
            writer.writerow([float(sim)]) 


def load_w2v_model(model_path=MODEL_PATH):
    model = gensim.models.KeyedVectors.load_word2vec_format(model_path, binary=True)
    return model

if __name__ == '__main__':
    # test this stuff out!
    print("Loading model")
    model = load_w2v_model(MODEL_PATH) 
    print("Model Loaded")

    document_as_list = "a i really like turtles and the sorts of food they eat turtles are felines".split()
    print(document_as_list)

    doc_as_vector, errs = doc_to_vector(document_as_list, model, do_normalize=True) 

    print("Here is the resulting document")
    print(doc_as_vector)
    print("and here is the magnitude:")
    print(norm(doc_as_vector))
    print("and here are the words that failed lookup:")
    for x in errs:
        print("\t%s" %x)

    #now let's make sure the sim stuff makes sense
    gold_standard = ['i', 'love', 'cats', 'and', 'puppies', 'they', 'eat', 'kibble']
    gsv, _ = doc_to_vector(gold_standard, model)
    doc2 = 'this is a document about computers and language'.split()
    dv2, _ = doc_to_vector(doc2, model)

    all_docs = [doc_as_vector, dv2]
    calculate_all_sims(gsv, all_docs, outfile_path="test_sim.csv")

    print('we also wrote out the cos sim between the document and gold standard. the sim for row 1 should be highest.')