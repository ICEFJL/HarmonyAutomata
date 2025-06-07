export interface ResponseType<T> {
  status: boolean;
  message: string;
  data: T;
}

export interface PageType {
  total: number;
  currentPage: number;
  pageSize: number;
  totalPage: number;
}


export interface ExcerciseResponseDataType<T> {
  "excercises": T[];
  "pagination": PageType;
}

export interface StudentResponseDataType<T> {
  "users": T[];
  "pagination": PageType;
}

export interface ExcerciseDetailResponseType<T> {
  "excercise": T;
}

export interface  AnswerResponseDataType<T> {
  result: T[];
}