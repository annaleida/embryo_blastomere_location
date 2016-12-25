# NOTE: This is a test of extractin initial circles for the inference computation using morphology. 
# It has now been transferred to Mtlab (160425) while testing. This code is not in use

from pylab import *
import csv
import skimage.feature as feat
from skimage.filters import roberts, sobel, scharr, canny, prewitt
import numpy as np
import skimage.morphology as morph
import skimage.exposure as exp
import skimage.filters as filt
import skimage.transform as trans
import skimage.draw as dr
from skimage.filters.rank import bottomhat, tophat

path = 'C:\\MMU\\HMC data\\Fertilitech test images\\12_3\\'
storeResultsPath = 'C:\\Temp\\'

# Help functions *************************************************************
def ConvertToStringIndex(number):
	# Add a 0 to all numbers under ten and return string of the number
	numberStr = str(number)
	if (number in linspace(0,9,10)):
		numberStr = "0" + str(number)
	return numberStr

def CheckIntersection(cell1, cell2,minDist1,minDist2):
	# Check if bodies overlap to any extent. Return 1 if they do
	delta_x = abs(cell1[0]-cell2[0])
	delta_y = abs(cell1[1]-cell2[1])
	# print 'idx: ' + str(idx)
	# print 'idx2: ' + str(idx2)
	dist = np.sqrt(delta_x**2+delta_y**2)
	# print 'dist ' + str(dist)
	# print 'radius: ' + str(fc[2])
	cellBig = cell1 if cell1[2] > cell2[2] else cell2
	cellSmall = cell2 if cell2[2] <= cell1[2] else cell1
	if dist < cellBig[2]*minDist1:
		return 1
	if dist + cellSmall[2] < cellBig[2]*minDist2:
		return 1

def TestAllLessThan(iterable, maxVal):
    for element in iterable:
        if element >= maxVal:
            return False
    return True


def DoMorphology(I):
	# TODO try varieties
	# edges = canny(image_gray, sigma=2.0,low_threshold=0.55, high_threshold=0.8)
	figure(11)
	gray()
	subplot(3,3,8)
	imshow(I)
	xticks([]), yticks([])
	title('Original image')
	# Tested not good for GFP
	strel5 = morph.disk(7)
	strel3 = morph.disk(3)
	dilateI = morph.dilation(I, strel3)

	I2 = filt.gaussian_filter(I,sigma = 1)
	
	I3 = morph.dilation(feat.canny(I2),strel3)
	I4 = morph.opening(I3,strel5)
	I5 = morph.remove_small_objects(I4,500)
	I6 = morph.binary_closing(I5,strel5)
	I5 = morph.remove_small_holes(I5,500)
	I8 = bottomhat(I6,strel5)
	I7 = morph.convex_hull_image(I6)
	
	edge_roberts = roberts(I)
	edge_sobel = sobel(I)
	edge_scharr = scharr(I)
	edge = edge_sobel

	bin_dilateI = morph.binary_dilation(I, strel3)
	openI = morph.opening(dilateI, strel3)
	rescaleI = exp.rescale_intensity(dilateI)
	otsu_thres = filt.threshold_otsu(1.0*dilateI)
	otsuI = I > otsu_thres
	openIotsu = morph.opening(otsuI, strel3)
	thresI = I > 0.5*np.max(openI)
	edgeIotsu = feat.canny(dilateI)
	adaptiveI = filt.threshold_adaptive(1.0*dilateI, 40, offset = 10)

	subplot(3,3,1)
	imshow(I2)
	xticks([]), yticks([])
	title('I2')
	# text(0.5,0.5, 'Original image',ha='center',va='center',size=24)
	
	subplot(3,3,2)
	imshow(I3)
	xticks([]), yticks([])
	# text(0.5,0.5, 'subplot(2,1,2)',ha='center',va='center',size=24)
	title('I3')

	subplot(3,3,3)
	imshow(I4)
	xticks([]), yticks([])
	title('I4')
	# text(0.5,0.5, 'Original image',ha='center',va='center',size=24)

	subplot(3,3,4)
	imshow(I5)
	xticks([]), yticks([])
	title('I5')

	subplot(3,3,5)
	imshow(I6)
	xticks([]), yticks([])
	# text(0.5,0.5, 'subplot(2,1,2)',ha='center',va='center',size=24)
	title('I6')

	subplot(3,3,6)
	imshow(I7)
	xticks([]), yticks([])
	# text(0.5,0.5, 'subplot(2,1,2)',ha='center',va='center',size=24)
	title('I7')

	subplot(3,3,7)
	imshow(I8)
	xticks([]), yticks([])
	# text(0.5,0.5, 'subplot(2,1,2)',ha='center',va='center',size=24)
	title('I8')
	return I3

def PerformHough(edgeMap, minRadius, maxRadius, numberOfBodies):
	hough_radii = np.arange(minRadius, maxRadius, 2) 
	hough_res = trans.hough_circle(edgeMap, hough_radii)

	centers = []
	accums = []
	radii = []

	for radius, h in zip(hough_radii, hough_res):
	    # For each radius, extract num_peaks circles
	    num_peaks = numberOfBodies
	    peaks = feat.peak_local_max(h, num_peaks=num_peaks)
	    centers.extend(peaks)
	    accums.extend(h[peaks[:, 0], peaks[:, 1]])
	    radii.extend([radius] * num_peaks)
	#draw most prominent num_peaks_draw
	num_peaks_draw = numberOfBodies
	circles = []
	
	for idx in np.argsort(accums)[::-1][:num_peaks_draw]:
		center_x, center_y = centers[idx]
		radius = radii[idx]
		circles.append([center_x, center_y, radius])
	return circles


def PerformFiltering(circles1, circles2, minDist1, minDist2, returnNbrOfBodies):
	# Compare positions of circles from Circles1 to all instances in Circles2. 
	# Circles1 are computed, Circles2 is only for comparison
	# Compute a confidence-matrix size nxm = (circles1xcircles2) 
	# where element[n][m] is the confidence of keeping circle n on the basis of 
	# the circle at position m.
	# return the number (returnNbrOfBodies) of circles from each set with the highest confidence (sum row-wise)
	size1 = np.array(circles1).shape
	size2 = np.array(circles2).shape
	conf_mat = np.ones((size1[0],size2[0]))
	idx_delete = []
	# print circles
	idx = 0
	for fc in circles1:
		# print fc
		idx2 = 0
		for c in circles2:
			if ((idx != idx2)&(fc[2] <= c[2])&(~(idx2 in idx_delete))):
				delta_x = abs(fc[0]-c[0])
				delta_y = abs(fc[1]-c[1])
				# print 'idx: ' + str(idx)
				# print 'idx2: ' + str(idx2)
				dist = np.sqrt(delta_x**2+delta_y**2)
				# print 'dist ' + str(dist)
				# print 'radius: ' + str(fc[2])
				if CheckIntersection(fc,c,minDist1, minDist2):
					if fc[2] <= c[2]:
						idx_delete.append(idx)
						conf_mat[idx][idx2] = conf_mat[idx][idx2]*0.5
						# conf_mat[idx2][idx] = conf_mat[idx2][idx]*1.5
						# print 'Deleting: ' + str(fc) + 'on acc of ' + str(c)
						# print tmpFilteredCircles
			idx2 = idx2 + 1
		idx = idx + 1
	# print idx_delete
	# print conf_mat
	conf_v = sum(conf_mat,1)
	conf_vs_id = argsort(conf_v) # sorts ascending
	# print conf_vs_id
	idx_delete = conf_vs_id[0:len(conf_vs_id)-returnNbrOfBodies]
	idx_delete = sort(idx_delete)[::-1]
	# print idx_delete
	if len(idx_delete) < len(circles1):
		for i in idx_delete:
			circles1 = np.delete(circles1,i,0)
	else:
		circles1 = []
	# print filteredCircles
	print 'Cells before filtering: ' + str(len(circles2))
	print 'Cells after filtering: ' + str(len(circles1))
	
	return circles1

def PlotCircles(I, mask, circlesPlot, name, figureHandle):
	circlesI = I.copy() # Prepare plotting
	for circ in circlesPlot:
		# print circ
		cx, cy = dr.circle_perimeter(circ[0], circ[1], circ[2])
		if ((TestAllLessThan(cx,mask["x_range"])) & (TestAllLessThan(cy,mask["y_range"]))):
			circlesI[cy, cx] = (220, 20, 20)
	figureHandle
	imshow(circlesI)
	title(name)

def ComputeCellPositions(I, pars, var):
	# Some morphology ********************************************************
	# TODO: combine different edge finders, extract focal plane, 
	edgeIn = DoMorphology(I)
	print '*** Morphology complete'

	# Hough *********************************************************************
	# TODO: detect embryo pos and exclude cells outside edge
	#hough_radii = np.arange(40, 100, 5) #gfp
	circlesHough = PerformHough(edgeIn, var["HoughMinRad"], var["HoughMaxRad"], var["HoughNbrBodies"]) #rfp
	print '*** Hough complete'
	figure(2)
	h = subplot(1,2,1)
	PlotCircles(pars["Irgb"], pars["ImageROI"], circlesHough, 'HoughCircles', h)
	# Filter *********************************************************************
	# TODO: combine to mean of close locations, create probabilitymatrix from different edge finders
	circlesHough2 = np.copy(circlesHough)
	circles = PerformFiltering(circlesHough, circlesHough2, var["FilteringMinDist1"], var["FilteringMinDist2"], var["FilteringReturnNbrBodies"])
	print '*** Filtering complete'
	h = subplot(1,2,2)
	PlotCircles(pars["Irgb"], pars["ImageROI"], circles, 'Filtered circles', h)
	return circles

def CompareCellLocations(predicted, truth):
	size1 = np.array(predicted).shape
	size2 = np.array(truth).shape
	error_mat = np.zeros((size1[0],size2[0]))
	idp = 0
	for p in predicted:
		idt = 0
		for tr in truth:
			delta_x = abs(p[0]-tr[0])
			delta_y = abs(p[1]-tr[1])
			# print 'idx: ' + str(idx)
			# print 'idx2: ' + str(idx2)
			dist = np.sqrt(delta_x**2+delta_y**2)
			error_mat[idt,idp] = dist
			idt = idt + 1
		idp = idp + 1
	print "*** CompareCellLocations complete"
	return error_mat
def ExtractAndSaveCellPositions():
	# This function is for testing
	mode = 'tl' # gfp, rfp, tl
	t_range = [10]#np.linspace(0,23,24)
	z_range = [17]
	parameters = {"mode":mode}
	variables = {"HoughMinRad":60, "HoughMaxRad":70, "HoughNbrBodies": 5, "FilteringMinDist1":0.75, "FilteringMinDist2":1.1}
	variables["FilteringReturnNbrBodies"] = 2
	# mask["x_range"] = 512
	# mask["y_range"] = 512
	mask = {"x_range":512,"y_range":512}
	parameters["ImageROI"] = mask
	# Loop images ****************************************************************
	for t in t_range:
		t = int(t)
		for z in z_range:
			# for t in range(24):
			# for z in range(78):
			fullPath = path + 't_' + ConvertToStringIndex(t) + '\\' + mode + '_z' + ConvertToStringIndex(z) + '_t' + ConvertToStringIndex(t) + '.png'
			Iin = imread(fullPath)
			Irgb = Iin.copy()
			parameters["t"] = t
			parameters["z"] = z
			parameters["Irgb"] = Irgb
			Iin = Iin[:,:,0] #R
			print '*** Initiated image(z,t): (' + str(z) + ',' + str(t) + ')'

			circlesFiltered = ComputeCellPositions(Iin,parameters, variables)
			results = []
			for circ in circlesFiltered:
				# print circ
				results.append([mode, z, t, circ[0], circ[1], circ[2]])

			# plt.savefig('../figures/subplot-horizontal.png', dpi=64)
			print '*** Plotting complete'
			# print len(results)
			show()

	# save to csv ***************************************************************************''
	fullStorePath = storeResultsPath + mode + '_z' + ConvertToStringIndex(z) + '.csv' 
	with open(fullStorePath, 'wb') as csvfile:
		csvwriter = csv.writer(csvfile, delimiter=';',quotechar='|', quoting=csv.QUOTE_MINIMAL)
		csvwriter.writerow(['mode', 'z','t','center x', 'center y', 'radius'])
		for res in circlesFiltered:
			csvwriter.writerow(res)
	print '*** Written to csv'


def ExtractAndCompareCellPositions():
	true_cirlces = [[260, 340, 0],[288,226,0],[200,150,0]] # for z17_t10, from watershed of gfp
	mode = 'tl' # gfp, rfp, tl
	t_range = [27]#np.linspace(0,23,24)
	z_range = [20]
	parameters = {"mode":mode}
	variables = {"HoughMinRad":30, "HoughMaxRad":90, "HoughNbrBodies": 10, "FilteringMinDist1":0.75, "FilteringMinDist2":1.1}
	variables["FilteringReturnNbrBodies"] = 3
	# mask["x_range"] = 512
	# mask["y_range"] = 512
	mask = {"x_range":500,"y_range":500}
	parameters["ImageROI"] = mask

	for t in t_range:
		t = int(t)
		for z in z_range:
			# for t in range(24):
			# for z in range(78):
			fullPath = path + 'D1900.01.01_S0012_I000_W03_P0' + ConvertToStringIndex(t) + '_F' + ConvertToStringIndex(z) + '.png'
			print fullPath
			Iin = imread(fullPath)
			Irgb = np.zeros((500,500,3))
			Irgb[:,:,0] = Iin.copy()
			Irgb[:,:,1] = Iin.copy()
			Irgb[:,:,2] = Iin.copy()
			parameters["t"] = t
			parameters["z"] = z
			parameters["Irgb"] = Irgb
			# Iin = Iin[:,:,0] #R
			print '*** Initiated image(z,t): (' + str(z) + ',' + str(t) + ')'

			circlesFiltered = ComputeCellPositions(Iin,parameters, variables)
			error_Location = CompareCellLocations(circlesFiltered, true_cirlces)
			print error_Location

	show()

# Start demo *****************************************************************

ExtractAndCompareCellPositions() #For testing

