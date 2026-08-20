package com.abusrar.assistant.core

sealed class AppResult<out T> {
    data class Success<T>(val data: T) : AppResult<T>()
    data class Error(val message: String, val code: Int = -1) : AppResult<Nothing>()
    data object Loading : AppResult<Nothing>()
}

fun <T> AppResult<T>.isSuccess(): Boolean = this is AppResult.Success
fun <T> AppResult<T>.isError(): Boolean = this is AppResult.Error
fun <T> AppResult<T>.isLoading(): Boolean = this is AppResult.Loading