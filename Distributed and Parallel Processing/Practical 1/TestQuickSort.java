/*
  Author: Dylan Smith
  Date: 1 August 2016
  QuickSort Test Program
*/

import java.util.Random;
import java.util.concurrent.*;
public class TestQuickSort {
  static final int ARRAY_SIZE = 1000000;
  public static void main (String [] args) {

    double meanParallel = 0;
    double meanSequential = 0;

    long durationPar = 0;
    long durationSeq = 0;

    for (int i = 0; i < 10; i++) {
      Integer [] arr = fillArray(ARRAY_SIZE);
      durationPar += qsortParallel(arr);
    }

    meanParallel = durationPar / 10;
    System.out.println("Mean parallel qsort execution time: " + meanParallel + "ms");

    for (int i = 0; i < 10; i++) {
      Integer [] arr = fillArray(ARRAY_SIZE);
      durationSeq += qsortSequential(arr);
    }

    meanSequential = durationSeq / 10;
    System.out.println("Mean sequential qsort execution time: " + meanSequential + "ms");

  } // main

  // Fill array with *size* elements
  private static Integer[] fillArray (int size) {
    Integer [] filledArray = new Integer[size];
    Random rng = new Random();
    for (int i = 0; i < filledArray.length; i++)
      filledArray[i] = rng.nextInt(100); // value between 0 - 100
    return filledArray;
  } // fill array

  // execute a parallel version of quickSort
  private static long qsortParallel (Integer [] toSort) {
    long startTime, endTime, duration;
    ForkJoinPool pool = new ForkJoinPool();

    startTime = System.currentTimeMillis();
    QuickSortPar qsortPar = new QuickSortPar(toSort, 0, toSort.length -1);
    pool.invoke(qsortPar);
    endTime = System.currentTimeMillis();
    duration  = endTime - startTime;

    System.out.println("Parallel sort time: "+ duration + "ms");
    return duration;
  } // qsortParallel

  // execute a sequential version of quicksort
  private static long qsortSequential (Integer[] toSort) {
    long startTime, endTime, duration;

    startTime = System.currentTimeMillis();
    QuickSortSeq.quickSort(toSort);
    endTime = System.currentTimeMillis();
    duration  = endTime - startTime;

    System.out.println("Sequential sort time: "+ duration + "ms");
    return duration;
  }
}
